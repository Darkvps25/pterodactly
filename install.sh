#!/usr/bin/env bash

# ==========================================
#  Pterodactyl Panel Installer
#  Created By: ItsDarkgame By
# ==========================================

set -e

echo "=========================================="
echo "   Pterodactyl Panel Installer"
echo "   Created By: ItsDarkgame By"
echo "=========================================="
sleep 2

# Check root
if [[ $EUID -ne 0 ]]; then
  echo "❌ Please run this script as root"
  exit 1
fi

# Check OS
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
else
  echo "❌ Cannot detect OS"
  exit 1
fi

if [[ "$ID" != "ubuntu" ]]; then
  echo "❌ This installer supports Ubuntu only"
  exit 1
fi

echo "✅ OS detected: Ubuntu $VERSION_ID"
sleep 1

# Update system
echo "🔄 Updating system..."
apt update && apt upgrade -y

# Install dependencies
echo "📦 Installing dependencies..."
apt install -y \
  curl \
  tar \
  unzip \
  git \
  redis-server \
  mariadb-server \
  nginx \
  software-properties-common \
  ca-certificates \
  gnupg \
  lsb-release

# Install PHP
echo "🐘 Installing PHP..."
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php8.1 php8.1-cli php8.1-gd php8.1-mysql php8.1-pdo \
php8.1-mbstring php8.1-tokenizer php8.1-bcmath php8.1-xml php8.1-curl zip unzip

# Install Composer
echo "🎼 Installing Composer..."
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Create panel directory
echo "📁 Creating Pterodactyl directory..."
mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl

# Download panel
echo "⬇️ Downloading Pterodactyl Panel..."
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/

# Install panel dependencies
echo "⚙️ Installing panel dependencies..."
composer install --no-dev --optimize-autoloader

# Environment setup
echo "🛠️ Setting up environment..."
cp .env.example .env
php artisan key:generate --force

echo "=========================================="
echo "✅ Base installation completed!"
echo ""
echo "Next steps (manual):"
echo "1. Configure database"
echo "2. Run: php artisan migrate --seed"
echo "3. Create admin user"
echo "4. Setup NGINX & SSL"
echo ""
echo "Installer by ItsDarkgame By"
echo "=========================================="
