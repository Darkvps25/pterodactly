#!/bin/bash

# --- Styling & Branding ---
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}==========================================${NC}"
echo -e "${GREEN}          MADE BY ITSDARK               ${NC}"
echo -e "${CYAN}==========================================${NC}"

show_menu() {
    echo -e "${CYAN}1)${NC} Install Cloudflare Tunnel"
    echo -e "${CYAN}2)${NC} Install Pterodactyl Panel"
    echo -e "${CYAN}3)${NC} Exit"
    echo -ne "${GREEN}Choose an option: ${NC}"
}

install_cloudflare() {
    clear
    echo -e "${GREEN}--- Installing Cloudflare Tunnel ---${NC}"
    
    # Install cloudflared
    curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared.deb
    
    echo -ne "${CYAN}Please enter your Cloudflare Tunnel Token: ${NC}"
    read TUNNEL_TOKEN
    
    # Run the tunnel as a service
    sudo cloudflared service install "$TUNNEL_TOKEN"
    
    echo -e "${GREEN}Cloudflare Tunnel connected to VPS!${NC}"
    sleep 3
}

install_ptero() {
    clear
    echo -e "${GREEN}--- Pterodactyl Panel Installation ---${NC}"
    echo "1) Install Pterodactyl Panel (Standard)"
    echo "2) Back to Menu"
    read -p "Select option: " ptero_choice

    if [ "$ptero_choice" == "1" ]; then
        echo -ne "${CYAN}Enter the Domain for your Panel (e.g. panel.example.com): ${NC}"
        read USER_DOMAIN
        
        echo -e "${GREEN}Starting installation for $USER_DOMAIN...${NC}"
        
        # This calls the official trusted automated installer
        bash <(curl -s https://pterodactyl-installer.se) <<EOF
0
$USER_DOMAIN
n
y
EOF
        echo -e "${GREEN}Pterodactyl installed on $USER_DOMAIN!${NC}"
    fi
}

# --- Main Logic ---
while true; do
    show_menu
    read choice
    case $choice in
        1) install_cloudflare ;;
        2) install_ptero ;;
        3) exit 0 ;;
        *) echo -e "${RED}Invalid option!${NC}" ; sleep 1 ;;
    esac
done
