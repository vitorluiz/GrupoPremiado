#!/bin/bash
source 00-start.sh


# INSTALANDO O DOCKER CE
echo Baixando o instalador do Docker CE
curl -fsSL https://get.docker.com -o get-docker.sh &>> $LOG
echo Instalando o Docker CE
#sh get-docker.sh &>> $LOG
#echo Instalado $(docker --version)
#echo Instalado $(docker compose --version)

# HABILITANDO O MODO SWARM NO DOCKER CE
#echo Habilitando o Docker Swarm
#docker swarm init $IP &>> $LOG
#docker swarm init --advertise-addr $IP &>> $LOG
rm ~/IP &>> $LOG


