#!/bin/bash
RED="\e[31m"
GREEN="\e[32m"
PURPLE="\e[36m"
ENDCOLOR="\e[0m"

curl -s https://raw.githubusercontent.com/nodeLogs/main/main/nodelogo.sh | bash
sleep 2
echo -e "${PURPLE}---------------------------------------${ENDCOLOR}"
echo -e "${PURPLE}>> Installing Prometheus...${ENDCOLOR}"
echo -e "${PURPLE}---------------------------------------${ENDCOLOR}"
sleep 2
sudo groupadd --system prometheus
sleep 1
sudo useradd -s /sbin/nologin --system -g prometheus prometheus
sleep 1
sudo mkdir /var/lib/prometheus
sleep 1
for i in rules rules.d files_sd; do sudo mkdir -p /etc/prometheus/${i}; done
sleep 1
sudo apt update
sleep 1
sudo apt -y install wget curl
sleep 1
mkdir -p /tmp/prometheus && cd /tmp/prometheus
sleep 1
curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep browser_download_url | grep linux-amd64 | cut -d '"' -f 4 | wget -qi -
sleep 1
tar xvf prometheus*.tar.gz
sleep 1
cd prometheus*/
sleep 1
sudo mv prometheus promtool /usr/local/bin/
sleep 1
sudo mv prometheus.yml /etc/prometheus/prometheus.yml
sleep 1
sudo mv consoles/ console_libraries/ /etc/prometheus/
sleep 1
cd $HOME
sleep 1
sudo tee /etc/systemd/system/prometheus.service<<EOF
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.external-url=

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF
sleep 1
for i in rules rules.d files_sd; do sudo chown -R prometheus:prometheus /etc/prometheus/${i}; done
sleep 1
for i in rules rules.d files_sd; do sudo chmod -R 775 /etc/prometheus/${i}; done
sleep 1
sudo chown -R prometheus:prometheus /var/lib/prometheus/
sleep 1
sudo systemctl daemon-reload
sudo systemctl enable prometheus
echo -e "${PURPLE}>> Prometheus has been successfully installed${ENDCOLOR}"