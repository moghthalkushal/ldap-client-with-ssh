# ldap-client-with-ssh
LDAP Client With SSH Ubuntu Container

LDAP Server and Client : https://www.youtube.com/watch?v=dIOgbLXyyQo

The current repo contains the docker file to create a container as an LDAP-Client with SSH Enabled

Download the docker file 

docker build -t ldap-client-local-build .

docker run -d --privileged -p 1235:22 ldap-client-local-build


Assumption:
Open LDAP Server is already running , in the current scenario its runnin with the IP 172.17.0.2 and LDAP_BASE : dc=jc,dc=be
Watch the video for the server creation

Easy steps:
https://drive.google.com/open?id=1MuaoxwKmFTHQ8Yn6-F-f7q8pcxkP2T9h

Download preconfigured ldap-server.tar and load it docker images, ensrue it is running on the IP 172.17.0.2 , or else you will have to change a lot of configuration 

docker load --input ldap-server-working.tar
docker run -it --privileged  ldap-server-working:latest
in the terminal restart slapd 
services slapd restart

(DOCKER FILE WORK IN PROGRESS)
