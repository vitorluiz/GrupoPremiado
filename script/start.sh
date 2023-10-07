#!/bin/bash
#Author: Vitor luiz macahdo
#Github: vitorluizmachado
#Version: 0.0.1
#Create at: 2023-10-07
##################################

# SCRIPT PATH
BASEDIR=$(pwd)
BASE=$BASEDIR/base.sh
# ACESSANDO O DIRETORIO ROOT
cd ~ 

# Obtem o endereço do ip do servidor
IP=$(curl -s ifconfig.me)
#read -p "Entre com o IP do Servidor: " IP
# Configura o arquivo de log
LOGSCRIPT="/var/log/$(echo $0 | cut -d'/' -f2)"
# Configuração da variável de Log utilizado nesse script
LOG=$LOGSCRIPT

#############################
#           MENU            #
#############################
PS3='Escolha a opção: '
options=(
    "Sistema Essêncial"
    "Instalar Docker"
    "Instalar Portainer" 
    "Stack - Traefik"
    "Stack - Evolution Api"
    "Stack - Postegres"
    "Stack - Redis"
    "Stack - Minio"
    "Stack - N8M"
    "Stack - Typebot"
    "Stack - Chatwoot"
    "Exit")
select opt in "${options[@]}"
do
    case $opt in
        "Sistema Essêncial")
            clear
            echo "Opção Escolhida: $opt"
            source $BASE

            ;;
        "Instalar Docker")
            echo "opção $opt"
            ;;
        "Instalar Portainer")
            echo "opção $opt"
            ;;
        "Stack - Traefik")
            echo "opção $opt"
            ;;
        "Stack - Evolution Api")
            echo "opção $opt"
            ;;
        "Stack - Postegres")
            echo "opção $opt"
            ;;
        "Stack - Redis")
            echo "opção $opt"
            ;;
        "Stack - Minio")
            echo "opção $opt"
            ;;
        "Stack - N8M")
            echo "opção $opt"
            ;;
        "Stack - Typebot")
            echo "opção $opt"
            ;;
        "Stack - Chatwoot")
            echo "opção $opt"
            ;;
        "Exit")
        echo -e "Pressione <Enter> para concluir o processo."
        read
        clear
        break
        ;;
        
    *) echo "invalid option $REPLY";;
    esac
done