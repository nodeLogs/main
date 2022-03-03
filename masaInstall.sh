#!/bin/bash
RED="\e[31m"
GREEN="\e[32m"
PURPLE="\e[36m"
ENDCOLOR="\e[0m"

curl -s https://raw.githubusercontent.com/nodeLogs/main/main/nodelogo.sh | bash
sleep 3
echo -e "  "
echo -e "  "
echo -e "${PURPLE}>> Обновляем пакеты${ENDCOLOR}"
sudo apt update && sudo apt upgrade -y
sleep 1
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential git make ncdu net-tools -y
echo -e "${GREEN}/// Успешно${ENDCOLOR}"
sleep 2
echo -e "${PURPLE}>> Устанавливаем GO 1.17.2${ENDCOLOR}"
sleep 2
ver="1.17.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version
echo -e "${GREEN}/// Успешно${ENDCOLOR}"
sleep 2
echo -e "${PURPLE}>> Билдим бинарник${ENDCOLOR}"
cd $HOME
sleep 1
rm -rf masa-node-v1.0
sleep 1
git clone https://github.com/masa-finance/masa-node-v1.0
sleep 2
cd masa-node-v1.0/src
sleep 1
git checkout v1.02
sleep 1
make all
sleep 2
cd $HOME/masa-node-v1.0/src/build/bin
sleep 1
sudo cp * /usr/local/bin
sleep 1
echo -e "${GREEN}/// Успешно${ENDCOLOR}"
echo -e "${PURPLE}>> Следуйте далее гайду${ENDCOLOR}"