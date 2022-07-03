#!/bin/bash
RED="\e[31m"
GREEN="\e[32m"
PURPLE="\e[36m"
ENDCOLOR="\e[0m"

sleep 2
echo -e "${PURPLE}---------------------------------------${ENDCOLOR}"
echo -e "${PURPLE}>> Installing Grafana...${ENDCOLOR}"
echo -e "${PURPLE}---------------------------------------${ENDCOLOR}"
echo -e "${PURPLE}by lateful${ENDCOLOR}"
sleep 2
sudo apt-get install -y gnupg2 curl software-properties-common
sleep 1
curl https://packages.grafana.com/gpg.key | sudo apt-key add -
sleep 1
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
sleep 1
sudo apt-get update
sleep 1
sudo apt-get -y install grafana
sleep 1
sudo systemctl enable --now grafana-server
sleep 1
echo -e "${PURPLE}>> Grafana has been successfully installed${ENDCOLOR}"
