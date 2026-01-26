#!/usr/bin/env bash

# ==========================================
# DarkGamer VPS + Pterodactyl Installer
# Created By: ItsDarkgame By
# ==========================================

set -e

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
  echo "           DarkGamer Installer"
  echo "           Created By ItsDarkgame By"
  echo "=========================================="
  echo -e "${RESET}"
}

pause() {
  read -p "Press Enter to continue..."
}

# ======================
# VPS INSTALL FUNCTION
# ======================
install_vps() {
  banner
  echo "Select VPS OS:"
  echo "1) Debian 13"
  echo "2) Ubuntu 22.04"
  echo "3) Other Linux"
  echo ""
  read -p "Choose OS: " os_choice

  case $os_choice in
    1) OS_NAME="Debian 13" ;;
    2) OS_NAME="Ubuntu 22.04" ;;
    3) OS_NAME="Other Linux" ;;
    *) echo -e "${RED}Invalid option${RESET}" ; pause; return ;;
  esac

  echo ""
  echo "VPS Options:"
  echo "1) START"
  echo "2) VM NUMBER"
  read -p "Choose option: " vps_option

  case $vps_option in
    1)
      echo -e "${GREEN}Starting VPS creation for $OS_NAME...${RESET}"
      sleep 2
      echo "(Simulation) VPS created ✔"
      ;;
    2)
      read -p "Enter VM NUMBER: " vm_number
      echo -e "${GREEN}Creating $OS_NAME VM #$vm_number...${RESET}"
      sleep 2
      echo "(Simulation) VM #$vm_number created ✔"
      ;;
    *) echo -e "${RED}Invalid option${RESET}" ; pause ;;
  esac

  pause
}

# ======================
# PANEL INSTALL FUNCTION
# ======================
install_panel() {
  banner
  echo -e "${GREEN}Installing Pterodactyl Panel...${RESET}"

  apt update && apt upgrade -y
  apt install -y curl tar unzip git redis-server mariadb-server nginx \
  software-properties-common ca-certificates gnupg lsb-release

  add-apt-repository ppa:ondrej/php -y
  apt update

  apt install -y php8.1 php8.1-cli php8.1-gd php8.1-mysql php8.1-pdo \
  php8.1-mbstring php8.1-tokenizer php8.1-bcmath php8.1-xml php8.1-curl zip unzip

  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer

  mkdir -p /var/www/pterodactyl
  cd /var/www/pterodactyl

  curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
  tar -xzvf panel.tar.gz
  chmod -R 755 storage/* bootstrap/cache/

  composer install --no-dev --optimize-autoloader
  cp .env.example .env
  php artisan key:generate --force

  echo -e "${GREEN}✅ Panel installation finished${RESET}"
  echo "Next: run php artisan migrate --seed and p:user:make"
  pause
}

# ======================
# WINGS INSTALL FUNCTION
# ======================
install_wings() {
  banner
  echo -e "${GREEN}Installing Pterodactyl Wings...${RESET}"

  apt update
  apt install -y curl ca-certificates gnupg lsb-release

  if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
    systemctl enable --now docker
  fi

  mkdir -p /etc/pterodactyl
  cd /etc/pterodactyl

  curl -Lo wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
  chmod +x wings

  cat > /etc/systemd/system/wings.service <<EOF
[Unit]
Description=Pterodactyl Wings
After=docker.service
Requires=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
ExecStart=/etc/pterodactyl/wings
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable wings

  echo -e "${GREEN}✅ Wings installed successfully${RESET}"
  echo "Upload config.yml and run: systemctl start wings"
  pause
}

# ======================
# CLOUDFLARE INSTALL FUNCTION
# ======================
install_cloudflare() {
  banner
  echo -e "${GREEN}Installing Cloudflare tools...${RESET}"
  apt update
  apt install -y curl wget unzip
  echo "(Simulation) Cloudflare setup complete ✔"
  pause
}

# ======================
# MAIN MENU LOOP
# ======================
while true; do
  banner
  echo "1) Install VPS"
  echo "2) Install Panel"
  echo "3) Install Wings"
  echo "4) Install Cloudflare"
  echo "5) Exit"
  echo ""
  read -p "Select an option: " main_option

  case $main_option in
    1) install_vps ;;
    2) install_panel ;;
    3) install_wings ;;
    4) install_cloudflare ;;
    5) exit 0 ;;
    *) echo -e "${RED}Invalid option${RESET}" ; sleep 1 ;;
  esac
done
