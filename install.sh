#!/bin/bash

# --- COLORS ---
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}====================================================${NC}"
echo -e "${GREEN}             MADE BY ITSDARK                       ${NC}"
echo -e "${CYAN}====================================================${NC}"

# --- Cloudflare Tunnel Fix ---
install_cloudflare() {
    clear
    echo -e "${CYAN}[1] Installing Cloudflare...${NC}"
    
    # Download and install the connector
    curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared.deb
    
    echo -e "${YELLOW}Paste your Tunnel Token from Cloudflare Dashboard:${NC}"
    read -p "Token: " CLOUDFLARE_TOKEN
    
    if [ -z "$CLOUDFLARE_TOKEN" ]; then
        echo -e "${RED}Error: Token is empty!${NC}"
        sleep 2
    else
        # This command actually connects it to the VPS
        sudo cloudflared service install "$CLOUDFLARE_TOKEN"
        echo -e "${GREEN}Cloudflare Tunnel is now ACTIVE!${NC}"
        sleep 3
    fi
}

# --- Pterodactyl Panel Fix ---
install_ptero() {
    clear
    echo -e "${CYAN}[2] Starting Pterodactyl Installer...${NC}"
    echo -e "${YELLOW}NOTE: When the installer asks for a choice, type it manually.${NC}"
    echo -e "${YELLOW}For the Panel, usually you type '0'.${NC}"
    sleep 2

    # We run the script WITHOUT automatic inputs so you can see the errors
    bash <(curl -s https://pterodactyl-installer.se)

    echo -e "${GREEN}Installer finished. Check above for any errors.${NC}"
    read -p "Press Enter to return to menu..."
}

# --- Main Menu ---
while true; do
    echo -e "\n${CYAN}--- MAIN MENU ---${NC}"
    echo -e "1) Install Cloudflare Tunnel"
    echo -e "2) Install Pterodactyl Panel"
    echo -e "3) Exit"
    echo -ne "${GREEN}Choose an option: ${NC}"
    read choice
    
    case $choice in
        1) install_cloudflare ;;
        2) install_ptero ;;
        3) exit 0 ;;
        *) echo -e "${RED}Invalid option!${NC}" ; sleep 1 ;;
    esac
done
