#!/bin/bash
#Author: Vitor luiz macahdo
#Github: vitorluizmachado
#Version: 0.0.1
#Create at: 2023-10-07
##################################

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
read -p "Hostname do servidor: " HOSTNAME
# Definindo o Timezone 
echo Definindo o Timezone para America/Sao_Paulo
timedatectl set-timezone America/Sao_Paulo &>> $LOG
# ATUALIZANDO E INSTALANDO OS PACOTES ESSENCIAIS
echo Atualizando os pacotes
apt update &>> $LOG
echo Instalando os pacotes essenciais
apt install build-essential git wget unzip curl apparmor apparmor-utils apache2-utils -y &>> $LOG
echo Atualizando o sistema
apt install upgrade -y &>> $LOG
hostnamectl set-hostname $HOSTNAME
;;
"Instalar Docker")
echo "opção $opt"
echo Baixando o instalador do Docker CE
curl -fsSL https://get.docker.com -o get-docker.sh &>> $LOG
echo Instalando o Docker CE
sh get-docker.sh &>> $LOG
echo Instalado $(docker --version)
echo Instalado $(docker compose --version)

# HABILITANDO O MODO SWARM NO DOCKER CE
echo Habilitando o Docker Swarm
docker swarm init $IP &>> $LOG
docker swarm init --advertise-addr $IP &>> $LOG
;;
"Instalar Portainer")
echo "opção $opt"
# PORTAINER
echo Instalando o Portainer
cd ~
mkdir portainer &>> $LOG
cd portainer &>> $LOG
read -p "Entre com o Domínio do Portainer: " DOMAIN_PORTAINER
read -p "Entre com o Domínio do Edge: " DOMAIN_EDGE
cat <<\EOF >> docker-compose.yml
version: "3.3"
services:
portainer:
    container_name: portainer
    image: portainer/portainer-ce:latest
    restart: always
    command: -H unix:///var/run/docker.sock
volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    - portainer_data:/data
labels:
    # Frontend
    - "traefik.enable=true"
    - "traefik.http.routers.frontend.rule=Host(`$DOMAIN_PORTAINER`)" #Coloque o Seu Dominio do Portainer Aqui
    - "traefik.http.routers.frontend.entrypoints=websecure"
    - "traefik.http.services.frontend.loadbalancer.server.port=9000"
    - "traefik.http.routers.frontend.service=frontend"
    - "traefik.http.routers.frontend.tls.certresolver=leresolver"
    # Edge
    - "traefik.http.routers.edge.rule=Host(`$DOMAIN_EDGE`)" #Coloque o Seu Dominio do Edge Aqui
    - "traefik.http.routers.edge.entrypoints=websecure"
    - "traefik.http.services.edge.loadbalancer.server.port=8000"
    - "traefik.http.routers.edge.service=edge"
    - "traefik.http.routers.edge.tls.certresolver=leresolver"

volumes:
    portainer_data:
EOF

echo Arquivo criado
;;
"Stack - Traefik")
echo "opção $opt"
read -p "Usuário do Traefik: " USERNAME 
read -s "Senha do Traefik: " PASSWORD
$USERNAME &>> $LOG
$PASSWORD &>> $LOG
read -p "E-mail para SSL Traefik: " EMAILSSL
read -p "Informe o Domínio para o Traefik: " TRAEFIKDOMINIO

# Arquivo de certificado de Segurança
echo Criando o arquivo de segurança Acme.json
touch acme.json &>> $LOG
echo alterando a permisão do arquivo Acme.json
chmod 600 acme.json &>> $LOG
# Gerando a senha 
echo Configurando a senha do Portainer
USERPWD=$(htpasswd -nbB $USERNAME $PASSWORD)

cat <<\EOF >> docker-compose.yml
version: "3.3"
services:
    traefik:
        container_name: traefik
        image: "traefik:latest"
        restart: always
        command:
            - --entrypoints.web.address=:80
            - --entrypoints.websecure.address=:443
            - --api.insecure=true
            - --api.dashboard=true
            - --providers.docker
            - --log.level=ERROR
            - --certificatesresolvers.leresolver.acme.httpchallenge=true
            - --certificatesresolvers.leresolver.acme.email=$EMAILSSL #Defina aqui seu endereço de e-mail, é para geração de certificados SSL com Let's Encrypt. 
            - --certificatesresolvers.leresolver.acme.storage=./acme.json
            - --certificatesresolvers.leresolver.acme.httpchallenge.entrypoint=web
        ports:
            - "80:80"
            - "443:443"
        volumes:
            - "/var/run/docker.sock:/var/run/docker.sock:ro"
            - "./acme.json:/acme.json"
        labels:
            - "traefik.http.routers.http-catchall.rule=hostregexp(`{host:.+}`)"
            - "traefik.http.routers.http-catchall.entrypoints=web"
            - "traefik.http.routers.http-catchall.middlewares=redirect-to-https"
            - "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"
            - "traefik.http.routers.traefik-dashboard.rule=Host(`$TRAEFIKDOMINIO`)" #Coloque o Seu Dominio do Traefik Aqui
            - "traefik.http.routers.traefik-dashboard.entrypoints=websecure"
            - "traefik.http.routers.traefik-dashboard.service=api@internal"
            - "traefik.http.routers.traefik-dashboard.tls.certresolver=leresolver"
            - "traefik.http.middlewares.traefik-auth.basicauth.users=$USERPWD" #Coloque a Senha do Traefik Aqui Nao Remova As Aspas
            - "traefik.http.routers.traefik-dashboard.middlewares=traefik-auth"
EOF
            ;;
        "Stack - Evolution Api")
            echo "opção $opt"
            read -p "Informe o Domínio da API: " EVOAPIDOMAIN
            read -p "Informe o nome da API: " NOMESUAAPAI
            GLOBAL_KEY=$(openssl rand -base64 24 | tr -d '\n')
            $GLOBAL_KEY &>> $LOG
            cd ~
            mkdir evolution_api
            cd evolution_api
            cat <<EOF > docker-compose.yml
            version: '3.8'
            services:
                evolution_api:
                    image: davidsongomes/evolution-api:latest
                    restart: always
                    volumes:
                    - evolution_instances:/evolution/instances
                    - evolution_store:/evolution/store
                    environment:
                        CONFIG_SESSION_PHONE_CLIENT: $NOMESUAAPAI
                        # Browser Name = Chrome | Firefox | Edge | Opera | Safari
                        CONFIG_SESSION_PHONE_NAME: Chrome
                        AUTHENTICATION_TYPE: apikey
                        AUTHENTICATION_API_KEY: $GLOBAL_KEY
                        AUTHENTICATION_EXPOSE_IN_FETCH_INSTANCES: true
                        ## Set the secret key to encrypt and decrypt your token and its expiration time
                        # seconds - 3600s ===1h | zero (0) - never expires
                        AUTHENTICATION_JWT_EXPIRIN_IN: 0
                        AUTHENTICATION_JWT_SECRET: "$GLOBAL_KEY"
                        # Temporary data storage
                        STORE_MESSAGES: true
                        STORE_MESSAGE_UP: true
                        STORE_CONTACTS: true
                        STORE_CHATS: true
                        # Set Store Interval in Seconds (7200 = 2h)
                        CLEAN_STORE_CLEANING_INTERVAL: 7200
                        CLEAN_STORE_MESSAGES: true
                        CLEAN_STORE_MESSAGE_UP: true
                        CLEAN_STORE_CONTACTS: true
                        CLEAN_STORE_CHATS: true
                        ## Define a global webhook that will listen for enabled events from all instances
                        WEBHOOK_GLOBAL_URL: ''
                        WEBHOOK_GLOBAL_ENABLED: false
                        # With this option activated, you work with a url per webhook event, respecting the global url and the name of each event
                        WEBHOOK_GLOBAL_WEBHOOK_BY_EVENTS: false
                        ## Set the events you want to hear  
                        WEBHOOK_EVENTS_APPLICATION_STARTUP: false
                        WEBHOOK_EVENTS_QRCODE_UPDATED: true
                        WEBHOOK_EVENTS_MESSAGES_SET: true
                        WEBHOOK_EVENTS_MESSAGES_UPSERT: true
                        WEBHOOK_EVENTS_MESSAGES_UPDATE: true
                        WEBHOOK_EVENTS_MESSAGES_DELETE: true
                        WEBHOOK_EVENTS_SEND_MESSAGE: true
                        WEBHOOK_EVENTS_CONTACTS_SET: true
                        WEBHOOK_EVENTS_CONTACTS_UPSERT: true
                        WEBHOOK_EVENTS_CONTACTS_UPDATE: true
                        WEBHOOK_EVENTS_PRESENCE_UPDATE: true
                        WEBHOOK_EVENTS_CHATS_SET: true
                        WEBHOOK_EVENTS_CHATS_UPSERT: true
                        WEBHOOK_EVENTS_CHATS_UPDATE: true
                        WEBHOOK_EVENTS_CHATS_DELETE: true
                        WEBHOOK_EVENTS_GROUPS_UPSERT: true
                        WEBHOOK_EVENTS_GROUPS_UPDATE: true
                        WEBHOOK_EVENTS_GROUP_PARTICIPANTS_UPDATE: true
                        WEBHOOK_EVENTS_CONNECTION_UPDATE: true
                        WEBHOOK_EVENTS_CALL: true
                        # This event fires every time a new token is requested via the refresh route
                        WEBHOOK_EVENTS_NEW_JWT_TOKEN: false
                        # This events is used with Typebot
                        WEBHOOK_EVENTS_TYPEBOT_START: false
                        WEBHOOK_EVENTS_TYPEBOT_CHANGE_STATUS: false
                        # This event is used with Chama AI
                        WEBHOOK_EVENTS_CHAMA_AI_ACTION: false
                        # This event is used to send errors
                        WEBHOOK_EVENTS_ERRORS: false
                        WEBHOOK_EVENTS_ERRORS_WEBHOOK:
                        # Set qrcode display limit
                        QRCODE_LIMIT: 30
                        QRCODE_COLOR: #198754
                    
                    labels:
                        - "traefik.enable=true"
                        #SSL
                        #Troque pelo seu dominio
                        - "traefik.http.routers.evolution_api.rule=Host(`$EVOAPIDOMAIN`)"
                        - "traefik.http.services.evolution_api.loadbalancer.server.port=8080"
                        - "traefik.http.routers.evolution_api.service=evolution_api"
                        - "traefik.http.routers.evolution_api.entrypoints=websecure"
                        - "traefik.http.routers.evolution_api.tls.certresolver=leresolver"

                    networks:
                        - evolutionapi

                networks:
                    evolutionapi:
                        external: true

                volumes:
                    evolution_instances:
                        evolution_store:
EOF
            echo "Salve sua API-KEY: " $GLOBAL_KEY
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
            ;;
        "Stack - Typebot")
echo "opção $opt"
# INPUT POSTGRESS
echo Informações para instalação do postgres
read -p "Banco Postgres: " BDPOSTGRES
read -s "Senha Postgres: " PWDPOSTGRES
# INPUT TYPEBOT
echo Informações para instalação do TYPEBOT
read -p "Entre com o Domínio do TYPEBOT BUILDER: " DOMAIN_BUILDER
read -p "Entre com o Domínio do TYPEBOT VIEWER: " DOMAIN_VIEWER
read -p "Entre com o Domínio do TYPEBOT STORAGE: " DOMAIN_STORAGE
SECRET_KEY=$(openssl rand -base64 24 | tr -d '\n')
$SECRET_KEY &>> $LOG
echo Informações do SMTP para TYPEBOT
read -p "E-mail Admin: " EMAIL_ADMIN
read -p "E-mail SMTP HOST: " EMAIL_SMTP_HOST
read -p "E-mail SMTP_PORT: " EMAIL_SMTP_PORT
read -p "E-mail SMTP_USERNAME: " EMAIL_SMTP_USERNAME
read -p "E-mail SMTP_PASSWORD: " EMAIL_SMTP_PASSWORD

# Criando rede para o typebot
echo Criando a rede para o Typebot em Driver Overlay
docker network create --driver=overlay typebot  &>> $LOG

cat <<\EOF>> docker-compose.yml
version: '3.7'
services:
  typebot-db:
    image: postgres:16
    restart: always
    volumes:
      - typebot_db_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=$BDPOSTGRES
      - POSTGRES_PASSWORD=$PWDPOSTGRES
    networks:
      - typebot

  typebot-builder:
    image: baptistearno/typebot-builder:latest
    restart: always
    depends_on:
      - typebot-db
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.typebot-builder.rule=Host(`$DOMAIN_BUILDER`)" # Troque pelo seu dominio ou subdominio
      - "traefik.http.routers.typebot-builder.entrypoints=web,websecure"
      - "traefik.http.routers.typebot-builder.tls.certresolver=leresolver"
    environment:
      - DATABASE_URL=postgresql://postgres:$BDPOSTGRES@typebot-db:5432/typebot
      - NEXTAUTH_URL=https://$DOMAIN_BUILDER # Troque pelo seu dominio ou subdominio
      - NEXT_PUBLIC_VIEWER_URL=https://$DOMAIN_VIEWER # Troque pelo seu dominio ou subdominio
      - ENCRYPTION_SECRET=$SECRET_KEY
      - ADMIN_EMAIL=$EMAIL_ADMIN # Troque pelo seu email
      - DISABLE_SIGNUP=false # Mude Para false caso queira permitir que outras pessoas criem contas é nescessario estar como false no primeiro login do administrador
      - SMTP_AUTH_DISABLED=false
      - SMTP_SECURE=true # Troque para false seu nao usar a porta 465 ou se estiver enfretando problemas no login
      - SMTP_HOST=$EMAIL_SMTP_HOST # Troque pelo seu SMTP USE SOMENTE DOMINIO PROPRIETARIOS
      - SMTP_PORT=$EMAIL_SMTP_PORT # altere aqui se nescessario portas comuns 25, 587, 465, 2525
      - SMTP_USERNAME=$EMAIL_SMTP_USERNAME # Troque pelo seu email
      - SMTP_PASSWORD=$EMAIL_SMTP_PASSWORD # Troque pela sua senha
      - NEXT_PUBLIC_SMTP_FROM=$EMAIL_SMTP_USERNAME # Troque pelo seu email
      - S3_ACCESS_KEY=minio # Troque se necessario
      - S3_SECRET_KEY=minio123 # Troque se necessario
      - S3_BUCKET=typebot
      - S3_ENDPOINT=$DOMAIN_STORAGE # Troque pelo seu dominio ou subdominio
    networks:
      - typebot

  typebot-viewer:
    image: baptistearno/typebot-viewer:latest
    restart: always
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.typebot-viewer.rule=Host(`$DOMAIN_VIEWER`)" # Troque pelo seu dominio ou subdominio
      - "traefik.http.routers.typebot-viewer.entrypoints=web,websecure"
      - "traefik.http.routers.typebot-viewer.tls.certresolver=leresolver"
    environment:
      - DATABASE_URL=postgresql://postgres:$BDPOSTGRES@typebot-db:5432/typebot
      - NEXTAUTH_URL=https://$DOMAIN_BUILDER # Troque pelo seu dominio ou subdominio
      - NEXT_PUBLIC_VIEWER_URL=https://$DOMAIN_VIEWER # Troque pelo seu dominio ou subdominio
      - ENCRYPTION_SECRET=$SECRET_KEY
      - SMTP_HOST=$EMAIL_SMTP_HOST # Troque pelo seu SMTP USE SOMENTE DOMINIO PROPRIETARIOS
      - NEXT_PUBLIC_SMTP_FROM=$EMAIL_SMTP_USERNAME # Troque pelo seu email
      - S3_ACCESS_KEY=minio # Troque se necessario - Deve ser Igual ao Declarado no Typebot Builder S3_ACCESS_KEY=
      - S3_SECRET_KEY=minio123 # Troque se necessario - Deve ser Igual ao Declarado no Typebot Builder S3_SECRET_KEY=
      - S3_BUCKET=typebot
      - S3_ENDPOINT=$DOMAIN_STORAGE # Troque pelo seu dominio ou subdominio
    networks:
      - typebot

  mail:
    image: bytemark/smtp
    restart: always
    networks:
      - typebot

  minio:
    image: minio/minio
    restart: always
    command: server /data
    ports:
      - '9000:9000'
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.minio.rule=Host(`$DOMAIN_STORAGE`)" # Troque pelo seu dominio ou subdominio
      - "traefik.http.routers.minio.entrypoints=web,websecure"
      - "traefik.http.routers.minio.tls.certresolver=leresolver"
    environment:
      MINIO_ROOT_USER: minio # Troque se necessario - Deve ser Igual ao Declarado no Typebot Builder S3_ACCESS_KEY=
      MINIO_ROOT_PASSWORD: minio123 # Troque se necessario - Deve ser Igual ao Declarado no Typebot Builder S3_SECRET_KEY=
    volumes:
      - typebot_s3_data:/data
    networks:
      - typebot

  createbuckets:
    image: minio/mc
    depends_on:
      - minio
    entrypoint: >
      /bin/sh -c "
      sleep 10;
      /usr/bin/mc config host add minio http://minio:9000 minio minio123;
      /usr/bin/mc mb minio/typebot;
      /usr/bin/mc anonymous set public minio/typebot/public;
      exit 0;
      "
    networks:
      - typebot

volumes:
  typebot_db_data:
  typebot_s3_data:

networks:
  typebot:
    external: true
EOF
# Finalização do arquivo
echo Arquivo Finalizado

;;
        "Stack - Chatwoot")
            echo "opção $opt"
            echo "Em breve"
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