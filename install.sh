#!/bin/bash
#! /usr/bin/env bash
RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"
curl -s https://raw.githubusercontent.com/nodeLogs/main/main/nodelogo.sh | bash
echo "Устанавливаем необходимый софт"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_rust.sh | bash &>/dev/null
source ~/.cargo/env
sleep 1
echo "${GREEN}Весь необходимый софт установлен, копируем репозиторий${ENDCOLOR}"
git clone https://github.com/penumbra-zone/penumbra
cd $HOME/penumbra && git checkout 005-mneme
echo "Репозиторий успешно склонирован, начинаем билд"
cd $HOME/penumbra/
cargo build --release --bin pcli
echo "Билд закончен, создаем кошелек"
cd $HOME/penumbra/
cargo run --quiet --release --bin pcli wallet generate
echo "Кошелек успешно создан, следуйте по гайду дальше"
