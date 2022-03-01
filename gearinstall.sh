#!/bin/bash
RED="\e[31m"
GREEN="\e[32m"
PURPLE="\e[36m"
ENDCOLOR="\e[0m"

curl -s https://raw.githubusercontent.com/nodeLogs/main/main/nodelogo.sh | bash
echo -e "${PURPLE}>> Начинаем установку необходимого софта :)${ENDCOLOR}"
echo -e "${RED}Не закрывайте окно и не производите никаких действий во время работы установщика!${ENDCOLOR}"
sleep 5
echo -e "${PURPLE}>> Устанавливаем WASM${ENDCOLOR}"
rustup toolchain add nightly
rustup target add wasm32-unknown-unknown --toolchain nightly
echo -e "${GREEN}/// Успешно${ENDCOLOR}"
sleep 1
echo -e "${PURPLE}>> Скачиваем бинарные файлы${ENDCOLOR}"
sleep 3
wget https://builds.gear.rs/gear-nightly-linux-x86_64.tar.xz && \
tar xvf gear-nightly-linux-x86_64.tar.xz && \
rm gear-nightly-linux-x86_64.tar.xz && \
chmod +x gear-node
echo -e "${GREEN}/// Успешно${ENDCOLOR}"
sleep 1
echo -e "${PURPLE}>> Устанавливаем MAKE${ENDCOLOR}"
sleep 3
apt install make
echo -e "${GREEN}/// Успешно${ENDCOLOR}"
sleep 1
echo -e "${PURPLE}>> Клонируем репозиторий${ENDCOLOR}"
sleep 3
git clone https://github.com/gear-tech/gear.git
cd gear
echo -e "${GREEN}/// Успешно${ENDCOLOR}"
sleep 1
echo -e "${PURPLE}>> Компилируем репозиторий. Потребуется больше вермени!${ENDCOLOR}"
sleep 3
make node-release
echo -e "${GREEN}/// Успешно${ENDCOLOR}"
sleep 1
echo -e "${PURPLE}>> Создаем сервисный файл и конфиг${ENDCOLOR}"
sleep 1
cd /etc/systemd/system 
touch gear-node.service
echo -e "${GREEN}Установка успешна завершена. Следуйте дальнейшим командам из гайда.${ENDCOLOR}"
exit