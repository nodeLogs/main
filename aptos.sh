#!/bin/bash
RED="\e[31m"
GREEN="\e[32m"
PURPLE="\e[36m"
ENDCOLOR="${ENDCOLOR}"


curl -s https://raw.githubusercontent.com/nodeLogs/main/main/nodelogo.sh | bash && sleep 3
echo -e "${PURPLE}>> Установка зависимостей ${ENDCOLOR}" && sleep 1
sudo apt-get update & sudo apt-get install git -y
cd $HOME
rm -rf aptos-core
rm /usr/local/bin/aptos*
sudo mkdir -p /opt/aptos/data aptos aptos/identity

echo "=================================================="

echo -e "\e[1m\e[32m2. Cloning github repo... ${ENDCOLOR}" && sleep 1
git clone https://github.com/aptos-labs/aptos-core.git
cd aptos-core
git checkout origin/devnet &> /dev/null
cp $HOME/aptos-core/config/src/config/test_data/public_full_node.yaml $HOME/aptos
wget -P $HOME/aptos https://devnet.aptoslabs.com/genesis.blob
wget -P $HOME/aptos https://devnet.aptoslabs.com/waypoint.txt
sed -i.bak 's/\(from_config: \).*/\1"'$(cat $HOME/aptos/waypoint.txt)'"/g' $HOME/aptos/public_full_node.yaml
sed -i '/genesis_file_location: /c\    genesis_file_location: "'$HOME/aptos/genesis.blob'"' $HOME/aptos/public_full_node.yaml

echo "=================================================="

echo -e "${PURPLE}>> Установка необходимых зависимостей Aptos... ${ENDCOLOR}" && sleep 1
echo y | ./scripts/dev_setup.sh
source ~/.cargo/env

echo "=================================================="

echo -e "${PURPLE}>> Компиляция Aptos... ${ENDCOLOR}" && sleep 1
cargo build -p aptos-node --release

echo "=================================================="

echo -e "${PURPLE}>> Компиляция aptos-операционный инструмент ... ${ENDCOLOR}" && sleep 1
cargo build -p aptos-operational-tool --release

echo "=================================================="

echo -e "${PURPLE}>> Перемещаем aptos-node в /usr/local/bin/aptos-node ... ${ENDCOLOR}" && sleep 1
mv $HOME/aptos-core/target/release/aptos-node /usr/local/bin

echo "=================================================="

echo -e "${PURPLE}>> Перемещаем aptos-operational-tool в /usr/local/bin/aptos-operational-tool ... ${ENDCOLOR}" && sleep 1
mv $HOME/aptos-core/target/release/aptos-operational-tool /usr/local/bin

echo "=================================================="

echo -e "${PURPLE}>> Создание уникального идентификатора ноды ... ${ENDCOLOR}" && sleep 1

/usr/local/bin/aptos-operational-tool generate-key --encoding hex --key-type x25519 --key-file $HOME/aptos/identity/private-key.txt &> /dev/null
/usr/local/bin/aptos-operational-tool extract-peer-from-file --encoding hex --key-file $HOME/aptos/identity/private-key.txt --output-file $HOME/aptos/identity/peer-info.yaml > $HOME/aptos/identity/id.json
PEER_ID=$(sed -n 2p $HOME/aptos/identity/peer-info.yaml | sed 's/.$//')
PRIVATE_KEY=$(cat $HOME/aptos/identity/private-key.txt)
sed -i '/discovery_method: "onchain"$/a\
      identity:\
          type: "from_config"\
          key: "'$PRIVATE_KEY'"\
          peer_id: "'$PEER_ID'"' $HOME/aptos/public_full_node.yaml


echo "=================================================="

echo -e "${PURPLE}>> Создание systemctl службы ... ${ENDCOLOR}" && sleep 1

echo "[Unit]
Description=Subspace Farmer

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/aptos-node --config $HOME/aptos/public_full_node.yaml
Restart=always
RestartSec=10
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
" > $HOME/aptos-fullnode.service
mv $HOME/aptos-fullnode.service /etc/systemd/system

echo "=================================================="

echo -e "${PURPLE}>> Запускаем ноду ... ${ENDCOLOR}" && sleep 1

sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable aptos-fullnode
sudo systemctl restart aptos-fullnode

echo "=================================================="

echo -e "${PURPLE}>> Aptos FullNode запущена ${ENDCOLOR}"

echo "=================================================="

echo -e "${GREEN}>>Для остановки Aptos Node: ${ENDCOLOR}" 
echo -e "${PURPLE}>>    systemctl stop aptos-fullnode \n ${ENDCOLOR}" 

echo -e "${GREEN}>>Для старта Aptos Node: ${ENDCOLOR}" 
echo -e "${PURPLE}>>    systemctl start aptos-fullnode \n ${ENDCOLOR}" 

echo -e "${GREEN}>>Проверить логи Aptos Node: ${ENDCOLOR}" 
echo -e "${PURPLE}>>    journalctl -u aptos-fullnode -f \n ${ENDCOLOR}" 

echo -e "${GREEN}>>Проверить статус ноды: ${ENDCOLOR}" 
echo -e "${PURPLE}>>    curl 127.0.0.1:9101/metrics 2> /dev/null | grep aptos_state_sync_version | grep type \n ${ENDCOLOR}" 