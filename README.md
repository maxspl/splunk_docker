# Splunk_Docker

Bash script that allows you to deploy multiple Splunk instance on a single host. 
The tool automatically increments ports on each run. 

It is not secured, use it only for dev.
## Prerequisites

Docker installed.

## Usage

Modifiy the lines 87 and 92 if you want to install apps from URLs during deployment.
```
"SPLUNK_APPS_URL=http://10.0.0.1:8080/requirements/app1.tgz,http://10.0.0.1:8080/requirements/app2.tgz"
```
Run the script with container name and admin password.
```
./docker_builder.sh [ -c | --container_name ][ -p | --password ]
```
## Example
```
python.exe .\VT_IP_query.py
```
> docker_builder.sh -c dev_splunk01 -p AZERTY0123

--------------------------
SPLUNK DOCKER CUSTOM BUILDER
--------------------------


[INFO] - Available space: 332G

--------------------------

[INFO] - Next available web port (use this port to connect to the web console) : 8005
[INFO] - Next available forwarding port (add this port on the Splunk) : 1006
[INFO] - Next available API port : 8094

--------------------------

[INFO] - Building a new container...
[INFO] - Docker command :

sudo docker run -d -p 8005:8000 -p 1006:1001 -p 8094:8089 --name dev_splunk01
_____-e "SPLUNK_PASSWORD=AZERTY0123"
_____-e "SPLUNK_START_ARGS=--accept-license"
_____-e "SPLUNK_APPS_URL=http://10.0.0.1:8080/requirements/app1.tgz,
_______http://10.0.0.1:8080/requirements/app1.tgz" -it splunk/splunk:latest

[INFO] - Launching the command... Use 'sudo docker ps -a to check the container status
45460e361b82b87c6fc19fd8373dfc4f18a533f4d2f0f8816a8bf86970fe21b9
[INFO] - Waiting for the container to be up...
[INFO] - Waiting for the container to be up...
[INFO] - Waiting for the container to be up...
[INFO] - Waiting for the container to be up...
[INFO] - Waiting for the container to be up...
45460e361b82   splunk/splunk:latest   "/sbin/entrypoint.sh…"   2 minutes ago   Up 2 minutes (healthy)      8065/tcp, 8088/tcp, 8191/tcp, 9887/tcp, 9997/tcp, 0.0.0.0:1006->1001/tcp, :::1006->1001/tcp, 0.0.0.0:8005->8000/tcp, :::8005->8000/tcp, 0.0.0.0:8094->8089/tcp, :::8094->8089/tcp   dev_splunk01

[INFO] - Adding 1001 to listening ports...
WARNING: Server Certificate Hostname Validation is disabled. Please see server.conf/[sslConfig]/cliVerifyServerName for details.
Listening for Splunk data on TCP port 1001.
[INFO] - Done



--------------------------
CONTAINER BUILT : SPLUNK READY TO RECEIVE DATA
--------------------------

[WARNING] - URL to access the console : http://5.5.5.5:8005
[WARNING] - Username : admin - Password : AZERTY0123
[WARNING] - Forwarding port to configure on the parser : 1006
```

## License

[MIT](https://choosealicense.com/licenses/mit/)
