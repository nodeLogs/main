#!/bin/bash
exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
	echo ''
else
  sudo apt install curl -y < "/dev/null"
fi
echo "-------------------------------------------"
sleep 1 && curl -s https://raw.githubusercontent.com/nodeLogs/main/main/nodelogo.sh | bash && sleep 3
echo "-------------------------------------------"
echo -e 'Установка зависимостей\n' && sleep 1
sudo apt update
sudo apt install make clang pkg-config libssl-dev build-essential gcc xz-utils git curl vim tmux ntp jq llvm ufw -y < "/dev/null"
echo "-------------------------------------------"
echo -e 'Установка Rust\n' && sleep 1
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
rustup default stable
rustup update stable --force
echo "-------------------------------------------"
echo -e 'Клонируем snarkOS\n' && sleep 1
cd $HOME
git clone https://github.com/AleoHQ/snarkOS.git --depth 1 -b testnet2
cd snarkOS
echo "-------------------------------------------"
echo -e 'Устанавливаем snarkOS v2.0.0\n' && sleep 1
cargo build --release
sudo rm -rf /usr/bin/snarkos
sudo cp $HOME/snarkOS/target/release/snarkos /usr/bin
cd $HOME
echo "-------------------------------------------"
echo -e 'Создаем аккаунт Aleo \n' && sleep 1
mkdir $HOME/aleo
echo "-------------------------------------------
Ваш Aleo аккаунт:
-------------------------------------------
" >> $HOME/aleo/account_new.txt
date >> $HOME/aleo/account_new.txt
snarkos experimental new_account >> $HOME/aleo/account_new.txt && cat $HOME/aleo/account_new.txt && sleep 2
cat $HOME/aleo/account_new.txt
echo 'export ALEO_ADDRESS='$(cat $HOME/aleo/account_new.txt | awk '/Address/ {print $2}') >> $HOME/.bashrc && . $HOME/.bashrc
source $HOME/.bashrc
export ALEO_ADDRESS=$(cat $HOME/aleo/account_new.txt | awk '/Address/ {print $2}' | tail -1)
printf 'Ваш адрес майнера - ' && echo ${ALEO_ADDRESS} && sleep 1
echo -e 'Создаем сервисный файл Aleo...\n' && sleep 1
echo "[Unit]
Description=Aleo Client Node Testnet2
After=network-online.target
[Service]
User=$USER
ExecStart=/usr/bin/snarkos
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
" > $HOME/aleod.service
echo -e 'Creating a service for Aleo Miner...\n' && sleep 1
echo "[Unit]
Description=Aleo Miner Testnet2
After=network-online.target
[Service]
User=$USER
ExecStart=/usr/bin/snarkos --trial --miner $ALEO_ADDRESS
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
" > $HOME/aleod-miner.service
sudo mv $HOME/aleod.service /etc/systemd/system
sudo mv $HOME/aleod-miner.service /etc/systemd/system
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
echo -e 'Включаем Aleo ноду и майнер\n' && sleep 1
sudo systemctl enable aleod
sudo systemctl enable aleod-miner
#sudo systemctl restart aleod
sudo systemctl restart aleod-miner
echo -e "Устанавливаем обновления Aleo\n"
cd $HOME
wget -q -O $HOME/aleo_updater_WIP.sh https://api.nodes.guru/aleo_updater_WIP.sh && chmod +x $HOME/aleo_updater_WIP.sh
echo "[Unit]
Description=Aleo Updater Testnet2
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/snarkOS
ExecStart=/bin/bash $HOME/aleo_updater_WIP.sh
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
" > $HOME/aleo-updater.service
sudo mv $HOME/aleo-updater.service /etc/systemd/system
systemctl daemon-reload
systemctl enable aleo-updater
systemctl restart aleo-updater