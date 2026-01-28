#!/usr/bin/env bash

# ==========================================
# DarkGamer Full Installer with Cloudflare & Domain
# Created By: ItsDarkgame (Updated)
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
  echo " DarkGamer Full Installer"
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
# CLOUDFLARE CONNECT
# ======================
cloudflare_connect() {
  banner
  echo "Cloudflare integration"
  echo "---------------------"
  # Generate a "player code" for connecting
  CF_PLAYER_CODE=$(openssl rand -hex 4)
  echo -e "${YELLOW}Player connection code: ${CF_PLAYER_CODE}${RESET}"
  echo "Give this code to the player to connect their Cloudflare account."
  
  read -rp "Enter player's Cloudflare API Token: " CF_TOKEN
  read -rp "Enter player's Cloudflare Zone ID: " CF_ZONE

  mkdir -p ~/.darkgamer
  cat > ~/.darkgamer/cloudflare.conf <<EOF
PLAYER_CODE="$CF_PLAYER_CODE"
CLOUDFLARE_TOKEN="$CF_TOKEN"
CLOUDFLARE_ZONE="$CF_ZONE"
EOF

  echo -e "${GREEN}✅ Cloudflare info saved successfully!${RESET}"
  pause
}

# ======================
# PTERODACTYL PANEL
# ======================
install_ptero_panel() {
  banner
  echo -e "${GREEN}Installing Pterodactyl Panel...${RESET}"

  read -rp "Enter the domain for your Pterodactyl Panel (example: panel.mydomain.com): " PTERO_DOMAIN

  # Install dependencies
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

  # Configure domain in .env
  sed -i "s|APP_URL=.*|APP_URL=https://$PTERO_DOMAIN|" .env

  composer install --no-dev --optimize-autoloader
  php artisan key:generate --force

  # Configure nginx
  cat > /etc/nginx/sites-available/pterodactyl <<EOF
server {
    listen 80;
    server_name $PTERO_DOMAIN;

    root /var/www/pterodactyl/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

  ln -s /etc/nginx/sites-available/pterodactyl /etc/nginx/sites-enabled/pterodactyl
  nginx -t
  systemctl restart nginx

  echo -e "${GREEN}✅ Pterodactyl Panel Installed at https://$PTERO_DOMAIN${RESET}"
  echo "Next steps:"
  echo "cd /var/www/pterodactyl"
  echo "php artisan migrate --seed"
  echo "php artisan p:user:make"

  pause
}

# ======================
# PTERODACTYL WINGS
# ======================
install_wings() {
  banner
  echo -e "${GREEN}Installing Pterodactyl Wings...${RESET}"
  curl -Lo /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
  chmod +x /usr/local/bin/wings

  mkdir -p /etc/pterodactyl
  echo "{}" > /etc/pterodactyl/config.json

  echo -e "${GREEN}✅ Wings Installed (basic config)${RESET}"
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
    echo "2) Install Wings"
    echo "3) Cloudflare Connect"
    echo "4) Install Minecraft CPANEL"
    echo "5) Back"
    echo ""
    read -rp "Choose option: " panel_choice
    case $panel_choice in
      1) install_ptero_panel ;;
      2) install_wings ;;
      3) cloudflare_connect ;;
      4) install_minecraft_cpanel ;;
      5) return ;;
      *) echo -e "${RED}Invalid option${RESET}" ; sleep 1 ;;
    esac
  done
}

# ======================
# MAIN MENU
# ======================
while true; do
  banner
  echo "1) Install VPS (Simulation)"
  echo "2) Panel Menu"
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
