#!/bin/bash
RED="\e[31m"
GREEN="\e[32m"
PURPLE="\e[36m"
ENDCOLOR="\e[0m"

echo "####################################"
curl -s https://raw.githubusercontent.com/nodeLogs/main/main/nodelogo.sh | bash
echo "####################################"
if [ ! $ARCHWAY_NODENAME ]; then
	read -p "${PURPLE}Укажите имя ноды (без спецсимволов - только буквы и цифры): ${ENDCOLOR}" ARCHWAY_NODENAME
fi
sleep 1
ARCHWAY_CHAIN="augusta-1"
echo 'export ARCHWAY_CHAIN='$ARCHWAY_CHAIN >> $HOME/.profile
echo 'export ARCHWAY_NODENAME='$ARCHWAY_NODENAME >> $HOME/.profile
echo "####################################"
echo "${GREEN}Устанавливаем Docker...${ENDCOLOR}"
echo "####################################"
curl -s https://raw.githubusercontent.com/nodeLogs/main/main/install/docker.sh | bash &>/dev/null
echo "####################################"
echo "${GREEN}Успех. Устанавливаем UFW...${ENDCOLOR}"
echo "####################################"
curl -s https://raw.githubusercontent.com/nodeLogs/main/main/install/ufw.sh | bash &>/dev/null
echo "####################################"
echo "${GREEN}Успех. Устанавливаем Go...${ENDCOLOR}"
echo "####################################"
curl -s https://raw.githubusercontent.com/nodeLogs/main/main/install/go.sh | bash &>/dev/null
sudo apt install --fix-broken -y &>/dev/null
sudo apt install nano mc wget -y &>/dev/null
source .profile
source .bashrc
sleep 1
echo "${GREEN}Весь необходимый софт установлен${ENDCOLOR}"
echo "####################################"
docker create -it --name archway archwaynetwork/archwayd:augusta &>/dev/null
docker cp archway:/usr/bin/archwayd /usr/bin/archwayd &>/dev/null
docker rm archway -f &>/dev/null
docker rmi archwaynetwork/archwayd:augusta &>/dev/null
echo "${GREEN}Репозиторий успешно склонирован, начинаем билд${ENDCOLOR}"
echo "####################################"
archwayd config chain-id augusta-1
archwayd config keyring-backend file
archwayd init $ARCHWAY_NODENAME --chain-id $ARCHWAY_CHAIN &>/dev/null
wget -O $HOME/.archway/config/genesis.json "https://raw.githubusercontent.com/kuraassh/Nodes/main/Archway/genesis.json"
wget -qO $HOME/.archway/config/addrbook.json https://raw.githubusercontent.com/SecorD0/Archway/main/addrbook.json &>/dev/null
sed -i -e "s%^moniker *=.*%moniker = \"$ARCHWAY_NODENAME\"%; "\
"s%^seeds *=.*%seeds = \"2f234549828b18cf5e991cc884707eb65e503bb2@34.74.129.75:31076,c8890bcde31c2959a8aeda172189ec717fef0b2b@95.216.197.14:26656\"%; "\
"s%^persistent_peers *=.*%persistent_peers = \"1f6dd298271684729d0a88402b1265e2ae8b7e7b@162.55.172.244:26656\"%; "\
"s%^external_address *=.*%external_address = \"`wget -qO- eth0.me`:26656\"%; " $HOME/.archway/config/config.toml
echo "${GREEN}Билд закончен, переходим к инициализации ноды${ENDCOLOR}"
echo "####################################"
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/archway.service
[Unit]
  Description=archway Cosmos daemon
  After=network-online.target
[Service]
  User=$USER
  ExecStart=$(which archwayd) start
  Restart=on-failure
  RestartSec=3
  LimitNOFILE=4096
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl enable archway &>/dev/null
sudo systemctl daemon-reload
sudo systemctl restart archway

echo "${GREEN}Нода $ARCHWAY_NODENAME успешно установлена${ENDCOLOR}"
echo "####################################"