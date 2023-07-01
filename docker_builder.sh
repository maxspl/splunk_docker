containers=$(sudo docker ps | awk '{if(NR>1) print $NF}')
host=$(hostname)

# Check and parse args
POSITIONAL_ARGS=()

help()
{
    echo "Usage: ./docker_builder.sh [ -c | --container_name ]
               [ -p | --password ]"
    exit 2
}
VALID_ARGUMENTS=$# # Returns the count of arguments that are in short or long options

if [ "$VALID_ARGUMENTS" -ne 4 ]; then
  help
fi

while [[ $# -gt 0 ]]; do
  case $1 in
    -c|--container_name)
      container_name="$2"
      shift # past argument
      shift # past value
      ;;
    -p|--password)
      password="$2"
      shift # past argument
      shift # past value
      ;;
    --default)
      DEFAULT=YES
      shift # past argument
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters



available_space=$(df -BG | grep '/dev/root' | awk '{print $4}' | sed 's/G//g')
echo -e "\n--------------------------\nSPLUNK DOCKER CUSTOM BUILDER\n--------------------------\n\n\n[INFO] - Available space: ${available_space}G"

if (($available_space < 15)); then
    echo "[ERROR] - Not enough remaining space on /dev/root."
    exit
fi

web_port_mapped_list=()
i=0
for container in $containers
do
   if [ "$container" = "$1" ];then
           echo "[ERROR] - Container already exists. Chose another name"
           exit
   fi
    web_port_mapped=$(sudo docker inspect --format='{{(index (index .NetworkSettings.Ports "8000/tcp") 0).HostPort}}' $container)
    web_port_mapped_list[i]=$web_port_mapped
    i=$((i+1))
done

max_value=$((for value in "${web_port_mapped_list[@]}";do echo $value;done) | sort -n | tail -1)
max_value_suffix=$((${max_value: -3}))

next_available_web_port=$((8000+$max_value_suffix+1))
next_available_forward_port=$((1001+$max_value_suffix+1))
next_available_api_port=$((8089+$max_value_suffix+1))

echo -e "\n--------------------------\n"
echo "[INFO] - Next available web port (use this port to connect to the web console) : $next_available_web_port"
echo "[INFO] - Next available forwarding port (add this port on the Splunk) : $next_available_forward_port"
echo "[INFO] - Next available API port : $next_available_api_port"

#container_name=$1
echo -e "\n--------------------------\n"
echo "[INFO] - Building a new container..."

docker_cmd=$(echo 'sudo docker run -d -p '"$next_available_web_port"':8000 -p '"$next_available_forward_port"':1001 -p '"$next_available_api_port"':8089 --name '"$container_name"' -e "SPLUNK_PASSWORD='"$password"'" -e "SPLUNK_START_ARGS=--accept-license" -e "SPLUNK_APPS_URL=http://10.0.0.1:8080/requirements/app1.tgz,http://10.0.0.1:8080/requirements/app2.tgz" -it splunk/splunk:latest')

echo -e "[INFO] - Docker command :\n\n"$(echo $docker_cmd | sed 's/,/,\\n_______/g' | sed 's/ -e/\\n_____-e/g')
echo -e "\n[INFO] - Launching the command... Use 'sudo docker ps -a to check the container status"

sudo docker run -d -p "$next_available_web_port":8000 -p "$next_available_forward_port":1001 -p "$next_available_api_port":8089 --name ${container_name} -e "SPLUNK_PASSWORD=$password" -e "SPLUNK_START_ARGS=--accept-license" -e "SPLUNK_APPS_URL==http://10.0.0.1:8080/requirements/app1.tgz,http://10.0.0.1:8080/requirements/app2.tgz" -it splunk/splunk:latest

while ! sudo docker ps -a | grep  "$container_name" | grep "healthy";
do
    sleep 30
    echo "[INFO] - Waiting for the container to be up..."
done
echo -e "\n[INFO] - Adding 1001 to listening ports..."
sudo docker exec -u splunk ${container_name} /opt/splunk/bin/splunk enable listen 1001 -auth "admin:$password"
echo "[INFO] - Done"

public_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
echo -e "\n\n\n--------------------------\nCONTAINER BUILT : SPLUNK READY TO RECEIVE DATA\n--------------------------\n"
echo -e "[WARNING] - URL to access the console : http://$public_ip:$next_available_web_port"
echo -e "[WARNING] - Username : admin - Password : $password"
echo -e "[WARNING] - Forwarding port to configure on the parser : $next_available_forward_port"
