#!/bin/bash
# --- MADE BY ITSDARK ---
set -e

# Branding
clear
echo -e "\033[0;36m====================================================\033[0m"
echo -e "\033[0;32m             MADE BY ITSDARK                       \033[0m"
echo -e "\033[0;36m====================================================\033[0m"

echo -e "1) Install Cloudflare Tunnel"
echo -e "2) Install Pterodactyl Panel (AUTO-INSTALL)"
read -p "Select Choice: " main_choice

if [ "$main_choice" == "1" ]; then
    echo "Downloading Cloudflare..."
    curl -L -o cf.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cf.deb
    read -p "Enter CF Token: " CF_TOKEN
    sudo cloudflared service install "$CF_TOKEN"
    echo "Cloudflare Tunnel is Active!"

elif [ "$main_choice" == "2" ]; then
    echo -ne "\033[0;33mEnter Domain (e.g. control.lexomc.qzz.io): \033[0m"
    read MY_DOMAIN
    
    echo "Starting Pterodactyl Auto-Installation for $MY_DOMAIN..."
    sleep 2

    # This sends all answers to the installer so it never stops to ask
    bash <(curl -s https://pterodactyl-installer.se) <<EOF
0
panel
pterodactyl
$(openssl rand -base64 8)
Europe/London
admin@$MY_DOMAIN
admin@$MY_DOMAIN
admin
itdark
itdark
$(openssl rand -base64 8)
$MY_DOMAIN
y
y
y
EOF

    echo -e "\033[0;32mSUCCESS! Pterodactyl installed on $MY_DOMAIN\033[0m"
else
    echo "Exiting..."
    exit 1
fi
