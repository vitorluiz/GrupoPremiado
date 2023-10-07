#!/bin/bash

# Input info
read -p "Entre com o IP do Servidor: " IP

# ARQUIVO DE LOG
LOGSCRIPT="/var/log/$(echo $0 | cut -d'/' -f2)"

# Arquivo de configuração dos parâmetros utilizados nesse script
# source 00-parametros.sh
#
# Configuração da variável de Log utilizado nesse script
LOG=$LOGSCRIPT


echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG

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


# FIM
# script para calcular o tempo gasto (SCRIPT MELHORADO, CORRIGIDO FALHA DE HORA:MINUTO:SEGUNDOS)
# opção do comando date: +%T (Time)
HORAFINAL=$(date +%T)
# opção do comando date: -u (utc), -d (date), +%s (second since 1970)
HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
# opção do comando date: -u (utc), -d (date), 0 (string command), sec (force second), +%H (hour), %M (minute), %S (second), 
TEMPO=$(date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S")
# $0 (variável de ambiente do nome do comando)
echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Pressione <Enter> para concluir o processo."
read
exit 1