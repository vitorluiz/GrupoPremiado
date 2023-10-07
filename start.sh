#!/bin/bash

# Input info
read -p "Entre com o IP do Servidor: " IP &>> $LOG

# ARQUIVO DE LOG
LOGSCRIPT="/var/log/$(echo $0 | cut -d'/' -f2)"

# Arquivo de configuração dos parâmetros utilizados nesse script
# source 00-parametros.sh
#
# Configuração da variável de Log utilizado nesse script
LOG=$LOGSCRIPT

# ATUALIZANDO E INSTALANDO OS PACOTES ESSENCIAIS
apt update &>> $LOG && \ 
apt install build-essential git wget unzip curl apparmor apparmor-utils &>> $LOG && \ 
apt install upgrade -y &>> $LOG

# ACESSANDO O DIRETORIO ROOT
cd ~ &>> $LOG

# INSTALANDO O DOCKER CE
curl -fsSL https://get.docker.com -o get-docker.sh &>> $LOG
sh get-docker.sh &>> $LOG

# HABILITANDO O MODO SWARM NO DOCKER CE 
docker swarm init --advertise-addr $IP &>> $LOG

# PORTAINER
mkdir portainer && cd portainer &>> $LOG
curl -L https://downloads.portainer.io/ce2-19/portainer-agent-stack.yml -o portainer-agent-stack.yml &>> $LOG
docker stack deploy -c portainer-agent-stack.yml portainer &>> $LOG

# ACESSANDO O DIRETORIO ROOT
cd ~ &>> $LOG