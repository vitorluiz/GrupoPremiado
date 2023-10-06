#!/bin/bash

apt update && \ 
apt install build-essential git wget unzip curl apparmor apparmor-utils && \ 
apt install upgrade -y

# DOCKER CE
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh


# PORTAINER
mkdir portainer && cd portainer
curl -L https://downloads.portainer.io/ce2-19/portainer-agent-stack.yml -o portainer-agent-stack.yml
docker stack deploy -c portainer-agent-stack.yml portainer