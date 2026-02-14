#!/bin/bash

# --- COLORS & BRANDING ---
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

clear
echo -e "${CYAN}==========================================${NC}"
echo -e "${GREEN}          MADE BY ITSDARK               ${NC}"
echo -e "${CYAN}==========================================${NC}"

# --- Cloudflare Function ---
install_cloudflare() {
    echo -e "${CYAN}Installing Cloudflare...${NC}"
    curl -L -o cf.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cf.deb
    read -p "Enter your Cloudflare Token: " CF_TOKEN
    sudo cloudflared service install "$CF_TOKEN"
    echo -e "${GREEN}Cloudflare Connected!${NC}"
}

# --- Automatic Pterodactyl Function ---
install_ptero() {
    echo -e "${CYAN}Starting AUTO-INSTALL for Pterodactyl...${NC}"
    read -p "Enter your Domain (ex: control.lexomc.qzz.io): " USER_DOMAIN
    
    # These are the automatic answers for the installer:
    # 0 = Install Panel
    # Database Name, User, Password (Random), Timezone, Email, Admin details...
    
    bash <(curl -s https://pterodactyl-installer.se) <<EOF
0
panel
pterodactyl
$(openssl rand -base64 12)
Europe/Stockholm
admin@$USER_DOMAIN
admin@$USER_DOMAIN
admin
itdark
itdark
$(openssl rand -base64 12)
$USER_DOMAIN
y
y
y
EOF

    echo -e "${GREEN}DONE! Pterodactyl is installed on $USER_DOMAIN${NC}"
}

# --- Main Menu ---
echo -e "1) Install Cloudflare"
echo -e "2) Install Pterodactyl (AUTO-DOMAIN)"
read -p "Choice: " main_choice

case $main_choice in
    1) install_cloudflare ;;
    2) install_ptero ;;
    *) echo "Exit" ;;
esac
