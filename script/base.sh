#!/bin/bash

# SCRIPT PATH
source /script/start.sh

# Configuração da variável de Log utilizado nesse script
LOG=$LOGSCRIPT
# Definindo o Timezone 
echo Definindo o Timezone para America/Sao_Paulo
#timedatectl set-timezone America/Sao_Paulo &>> $LOG
# Iniciando o tempo do script
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
# ATUALIZANDO E INSTALANDO OS PACOTES ESSENCIAIS
echo Atualizando os pacotes
apt update &>> $LOG
echo Instalando os pacotes essenciais
apt install build-essential git wget unzip curl apparmor apparmor-utils apache2-utils &>> $LOG
echo Atualizando o sistema
apt install upgrade -y &>> $LOG
#hostnamectl set-hostnamem $HOSTNAME
# ACESSANDO O DIRETORIO ROOT
cd ~ &>> $LOG
./start.sh