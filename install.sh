#!/bin/bash
RED="\e[31m"
GREEN="\e[32m"
PURPLE="\e[36m"
ENDCOLOR="\e[0m"

curl -s https://raw.githubusercontent.com/nodeLogs/main/main/nodelogo.sh | bash
echo -e "${PURPLE}Устанавливаем необходимый софт${ENDCOLOR}"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_rust.sh | bash &>/dev/null
source ~/.cargo/env
sleep 1
echo -e "${GREEN}Весь необходимый софт установлен${ENDCOLOR}"
echo -e "${PURPLE}Копируем Репозиторий${ENDCOLOR}"
git clone https://github.com/penumbra-zone/penumbra
cd $HOME/penumbra && git checkout 005-mneme
echo -e "${GREEN}Репозиторий успешно склонирован${ENDCOLOR}"
echo -e "${PURPLE}Начинаем билд, ожидайте${ENDCOLOR}"
cd $HOME/penumbra/
cargo build --release --bin pcli
echo -e "${GREEN}Билд закончен${ENDCOLOR}"
echo -e "${PURPLE}Создаем кошлек${ENDCOLOR}"
cd $HOME/penumbra/
cargo run --quiet --release --bin pcli wallet generate
echo -e "${GREEN}Кошелек успешно создан${ENDCOLOR}"
echo -e "${GREEN}Вернитесь и следуйте гайду дальше${ENDCOLOR}"
