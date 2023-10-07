#!/bin/bash
# Arquivo de configuração dos parâmetros utilizados nesse script
source ../start.sh

GLOBAL_KEY=$(openssl rand -base64 24 | tr -d '\n')

echo $GLOBAL_KEY

echo $($EVOAPIDOMAIN.$DOMINIO)

echo O IP ENCONTRADO É: $IP


##################
#read -p "Entre com o Hostname do servidor: " HOSTNAME
read -p "Entre com seu DOMINIO Ex:meusite.com.br: " HOSTNAME


clear
echo Antes de fazer a instalação é necessário fazer os apontamentos DNS
echo Caso não fez faça.
echo 
echo
echo Digite a opção que deseja instalar:
echo "#######################################"
echo "# 0   Sistema Basico                  #"
echo "# 1 - Instalar Docker                 #"
echo "# 2 - Instalar PORTAINER              #"
echo "# 3 - Gerar Compose - TRAEFIK         #"
echo "# 4 - Gerar Compose - EVOLUTION API   #"
echo "# 5 - Gerar Compose - POSTGRES        #"
echo "# 6 - Gerar Compose - N8N             #"
echo "# 7 - Gerar Compose - TYPEBOT         #"
echo "# 8 - Gerar Compose - CHATWOOT        #"
echo "# q - Exit                            #"
echo "#######################################"
echo
read -p "Digite a opção que deseja: " USER_INPUT
clear
case $USER_INPUT  in 
0)
    echo "Instalação Essêncial"
    ./install/base.sh

    ;&
1)
    echo "Escolheu instalar Docker CE"
    ./install/docker.sh

    ;&
2)
    echo "Escolheu instalar Portainer"
    read -p "Sub-Domínio para Portainer: " PORTAINERDOMAIN
    ./install/portainer.sh

    ;&
3)
    echo "Escolheu instalar Traefik"
    read -p "Sub-Domínio para Traefik: " TRAEFIKDOMAIN
    read -p "Sub-Domínio para Edge: " EDGEDOMAIN
    ./install/traefik.sh

    ;&
4)  
    echo "Evolution Api"
    read -p "Dominio para EvolutionApi: " EVOAPIDOMAIN
    cd install
    ./evolution.sh

    ;&
5)
    echo "Gerar o Stack do Postgres"
    ./install/postgres.sh

    ;&
6)
    echo "Gerar o Stack do N8N"
    read -p "Dominio para n8n: " N8NDOMAIN
    ./install/n8n.sh

    ;&
7)
    echo Gerar o Stack do Typebot
    read -p "Dominio para Typebot: " TYPEBOTDOMAIN
    ./install/typebot.sh

    ;&
8)
    echo "Gerar o Stack Chatwoot"
    read -p "Dominio para Chatwoot: " CHATWOOTDOMAIN
    ./install/chatwoot.sh

    ;&
q)
    echo "Saindo do instalador"
    exit 1
esac

