#!/bin/bash

n8n_storage="/opt/beget/n8n/n8n_storage"
fdate=$(date +%Y-%m-%d)
vps_ip=$1
port_vps=${2:-"22"} 


echo "Эскпорт workflow и credentials на исходном сервере"

docker exec -u node -i n8n-n8n-1 n8n export:credentials --all --decrypted --output=/home/node/.n8n/credentials_${fdate}.json
docker exec -u node -i n8n-n8n-1 n8n export:workflow --all --output=/home/node/.n8n/workflow_${fdate}.json

echo "Перенос workflow и credentials на текущий сервер"

rsync -avz -e "ssh -p $port_vps" ${n8n_storage}/credentials_${fdate}.json root@${vps_ip}:${n8n_storage}/ 

rsync -avz -e "ssh -p $port_vps" ${n8n_storage}/workflow_${fdate}.json root@${vps_ip}:${n8n_storage}/

echo "Импорт на текущем сервере"

ssh -p $port_vps root@${vps_ip} "docker exec -i n8n-n8n-1 n8n import:workflow --input=/home/node/.n8n/workflow_${fdate}.json"
ssh -p $port_vps root@${vps_ip} "docker exec -i n8n-n8n-1 n8n import:credentials --input=/home/node/.n8n/credentials_${fdate}.json"
