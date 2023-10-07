#!/bin/bash

# Input info
read -p "Entre com o IP do Servidor: " IP

# ATUALIZANDO E INSTALANDO OS PACOTES ESSENCIAIS
apt update && \ 
apt install build-essential git wget unzip curl apparmor apparmor-utils && \ 
apt install upgrade -y

# ACESSANDO O DIRETORIO ROOT
cd ~

# INSTALANDO O DOCKER CE
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# HABILITANDO O MODO SWARM NO DOCKER CE 
docker swarm init --advertise-addr $IP

# PORTAINER
mkdir portainer && cd portainer
curl -L https://downloads.portainer.io/ce2-19/portainer-agent-stack.yml -o portainer-agent-stack.yml
docker stack deploy -c portainer-agent-stack.yml portainer

# ACESSANDO O DIRETORIO ROOT
cd ~