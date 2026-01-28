#!/usr/bin/env bash

# ==========================================
# DarkGamer Minecraft Panel Installer
# Created By: ItsDarkgame
# ==========================================

set -euo pipefail

# Colors
GREEN="\e[32m"
RED="\e[31m"
CYAN="\e[36m"
YELLOW="\e[33m"
RESET="\e[0m"

# Root check
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}❌ Run this script as root${RESET}"
  exit 1
fi

banner() {
  clear
  echo -e "${CYAN}"
  echo "=========================================="
  echo " DarkGamer Minecraft Installer"
  echo "=========================================="
  echo -e "${RESET}"
}

pause() { read -rp "Press Enter to continue..." ; }

# ======================
# VPS (SIMULATION)
# ======================
install_vps() {
  banner
  echo "VPS creation is a simulation only."
  echo -e "${GREEN}✔ VPS Ready${RESET}"
  pause
}

# ======================
# PTERODACTYL PANEL
# ======================
install_ptero_panel() {
  banner
  echo -e "${GREEN}Installing Pterodactyl Panel...${RESET}"
  apt update && apt upgrade -y
  apt install -y curl tar unzip git redis-server mariadb-server nginx \
    ca-certificates gnupg lsb-release software-properties-common
  add-apt-repository ppa:ondrej/php -y
  apt update
  apt install -y php8.1 php8.1-{cli,gd,mysql,mbstring,tokenizer,bcmath,xml,curl,zip}
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
  mkdir -p /var/www/pterodactyl
  cd /var/www/pterodactyl || exit 1
  curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
  tar -xzvf panel.tar.gz --strip-components=1
  chmod -R 755 storage bootstrap/cache
  cp .env.example .env
  composer install --no-dev --optimize-autoloader
  php artisan key:generate --force
  echo -e "${GREEN}✅ Pterodactyl Panel Installed${RESET}"
  echo -e "${YELLOW}Run next:${RESET}"
  echo "cd /var/www/pterodactyl"
  echo "php artisan migrate --seed"
  echo "php artisan p:user:make"
  pause
}

# ======================
# MINECRAFT CPANEL (CRAFTY)
# ======================
install_minecraft_cpanel() {
  banner
  echo -e "${GREEN}Installing Minecraft CPANEL (Crafty Controller)...${RESET}"
  apt update
  apt install -y git python3 python3-pip curl openjdk-17-jre
  cd /opt || exit 1
  git clone https://github.com/RMDC-Crafty/crafty-controller.git
  cd crafty-controller || exit 1
  pip3 install -r requirements.txt
  echo -e "${GREEN}Starting Crafty for first time...${RESET}"
  python3 main.py &
  echo -e "${GREEN}✅ Minecraft CPANEL Installed${RESET}"
  echo -e "${CYAN}Web Panel:${RESET} http://YOUR-IP:8000"
  pause
}

# ======================
# PANEL MENU
# ======================
panel_menu() {
  while true; do
    banner
    echo "1) Install Pterodactyl Panel"
    echo "2) Install Minecraft CPANEL"
    echo "3) Back"
    echo ""
    read -rp "Choose option: " panel_choice
    case $panel_choice in
      1) install_ptero_panel ;;
      2) install_minecraft_cpanel ;;
      3) return ;;
      *) echo -e "${RED}Invalid option${RESET}" ; sleep 1 ;;
    esac
  done
}

# ======================
# MAIN MENU
# ======================
while true; do
  banner
  echo "1) Install VPS"
  echo "2) Install Panel"
  echo "3) Exit"
  echo ""
  read -rp "Select option: " main_option
  case $main_option in
    1) install_vps ;;
    2) panel_menu ;;
    3) exit 0 ;;
    *) echo -e "${RED}Invalid option${RESET}" ; sleep 1 ;;
  esac
done
