#!/bin/bash

source 00-start.sh

# PORTAINER
echo Instalando o Portainer
mkdir portainer &>> $LOG
cd portainer &>> $LOG
# Arquivo de certificado de Segurança
echo Criando o arquivo de segurança Acme.json
touch acme.json &>> $LOG
echo alterando a permisão do arquivo Acme.json
chmod 600 acme.json &>> $LOG
# Gerando a senha 
echo Configurando a senha do Portainer
htpasswd -nbB $USERNAME $PASSWORD

cd ~
mkdir portainer
cd portainer
cat >> docker-compose.yml <<EOF
version: "3.8"

services:
  agent:
    image: portainer/agent:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /var/lib/docker/volumes:/var/lib/docker/volumes
    networks:
      - agent_network
    deploy:
      mode: global
      placement:
        constraints: [ node.platform.os == linux ]

  portainer:
    image: portainer/portainer-ce:latest
    command: -H tcp://tasks.agent:9001 --tlsskipverify
    ports:
      - 9000:9000
    volumes:
      - portainer_data:/data
    networks:
      - agent_network
      - traefik_public

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [ node.role == manager ]
      
      #labels:
        #- "traefik.enable=true"
        #- "traefik.docker.network=treaefik_public"
        #- "traefik.http.routers.portainer.rule=Host(`${PORTAINER.DOMINIO}`)"
        #- "traefik.http.routers.portainer.entrypoints=websecure"
        #- "traefik.http.routers.portainer.priority=1"
        #- "traefik.http.routers.portainer.tls.certresolver=le"
        #- "traefik.http.routers.portainer.service=portainer"
        #- "traefik.http.services.portainer.loadbalancer.server.port=9000"

networks:
  traefik_public:
    external: true
    attachable: true
  agent_network:
    external: true

volumes:
  portainer_data:
    external: true

EOF

#curl -L https://downloads.portainer.io/ce2-19/portainer-agent-stack.yml -o portainer-agent-stack.yml &>> $LOG
#docker stack deploy -c portainer-agent-stack.yml portainer &>> $LOG
