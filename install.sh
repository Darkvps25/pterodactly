#!/bin/bash

# =========================
# DarkGamer Installer
# Works on IDX
# =========================

NAME="DarkGamer"

clear

show_menu() {
    echo "=============================="
    echo "   $NAME Installer Menu"
    echo "=============================="
    echo "1) Install Panel (simulation)"
    echo "2) Install Wings (simulation)"
    echo "3) Install Cloudflare (API setup)"
    echo "4) Create VPS (INFO ONLY)"
    echo "5) Exit"
    echo "=============================="
    echo -n "Choose an option: "
}

install_panel() {
    echo
    echo "[+] Installing Panel (IDX safe mode)"
    echo "This is a simulation."
    echo "On a real VPS, this would install:"
    echo "- PHP"
    echo "- Nginx"
    echo "- MariaDB"
    echo "- Pterodactyl Panel"
    echo
    sleep 2
    echo "[✓] Panel simulation complete"
}

install_wings() {
    echo
    echo "[+] Installing Wings (IDX safe mode)"
    echo "This is a simulation."
    echo "On a real VPS, this would install:"
    echo "- Docker"
    echo "- Pterodactyl Wings"
    echo
    sleep 2
    echo "[✓] Wings simulation complete"
}

install_cloudflare() {
    echo
    echo "[+] Cloudflare setup"
    read -p "Enter Cloudflare API Token: " CF_TOKEN
    read -p "Enter Domain Name: " DOMAIN
    echo
    echo "[✓] Saved Cloudflare info (not uploaded anywhere)"
    echo "Domain: $DOMAIN"
}

create_vps() {
    echo
    echo "[!] VPS creation is NOT possible on IDX"
    echo
    echo "To auto-create a VPS, you need:"
    echo "- Oracle Cloud / AWS / DigitalOcean API"
    echo "- A real server environment"
    echo
    echo "Example (real world):"
    echo "curl -X POST cloud-provider-api"
    echo
    echo "This option is informational only."
}

while true; do
    show_menu
    read choice

    case $choice in
        1) install_panel ;;
        2) install_wings ;;
        3) install_cloudflare ;;
        4) create_vps ;;
        5) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option" ;;
    esac

    echo
    read -p "Press Enter to return to menu..."
    clear
done
