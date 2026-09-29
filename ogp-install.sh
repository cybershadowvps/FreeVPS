#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "[OGP] Please run this script as root: sudo bash ogp-install.sh"
  exit 1
fi

if [[ ! -f /etc/os-release ]]; then
  echo "[OGP] This installer expects a Debian/Ubuntu-based system."
  exit 1
fi

. /etc/os-release
case "$ID" in
  ubuntu|debian)
    ;;
  *)
    echo "[OGP] Unsupported distro: $ID"
    echo "[OGP] This script is intended for Ubuntu/Debian servers."
    exit 1
    ;;
 esac

echo "[OGP] Updating package list..."
apt-get update

echo "[OGP] Installing base dependencies..."
apt-get install -y --no-install-recommends \
  curl wget ca-certificates gnupg unzip git software-properties-common \
  php php-cli php-curl php-gd php-mbstring php-xml php-zip \
  mariadb-server mariadb-client nginx

echo "[OGP] Downloading official Open Game Panel Easy Installer..."
curl -fsSL https://raw.githubusercontent.com/OpenGamePanel/Easy-Installer/master/install.sh -o /tmp/ogp-installer.sh
chmod +x /tmp/ogp-installer.sh

if ! bash /tmp/ogp-installer.sh; then
  echo "[OGP] The official installer script failed."
  echo "[OGP] This usually means the upstream installer changed or the host is not supported."
  echo "[OGP] Please re-check the official OGP documentation and rerun this script later."
  exit 2
fi

echo "[OGP] Installation finished."
echo "[OGP] Open the web panel using your server IP and the configured OGP web port."
echo "[OGP] If you are using nginx/apache, make sure the panel is enabled and the firewall allows the required port."
