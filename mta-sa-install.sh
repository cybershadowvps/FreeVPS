#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "[MTA] Please run this script as root: sudo bash mta-sa-install.sh"
  exit 1
fi

if [[ ! -f /etc/os-release ]]; then
  echo "[MTA] This installer expects a Debian/Ubuntu-based system."
  exit 1
fi

. /etc/os-release
case "$ID" in
  ubuntu|debian)
    ;;
  *)
    echo "[MTA] Unsupported distro: $ID"
    exit 1
    ;;
 esac

echo "[MTA] Updating packages..."
apt-get update

echo "[MTA] Installing dependencies..."
apt-get install -y --no-install-recommends \
  curl wget unzip screen ca-certificates \
  libc6-i386 lib32gcc-s1

mkdir -p /srv/mta
cd /srv/mta

if [[ ! -f /srv/mta/mta-server64 ]]; then
  echo "[MTA] Downloading official MTA:SA Linux server package..."
  wget -O /tmp/mta-linux.tar.gz "https://linux.mtasa.com/dl/mta-linux-x64.tar.gz"
  tar -xzf /tmp/mta-linux.tar.gz --strip-components=1
fi

if [[ ! -f /srv/mta/mta-server64 ]]; then
  echo "[MTA] Download failed or package structure changed. Check the official MTA Linux download URL."
  exit 2
fi

echo "[MTA] Creating systemd service..."
cat > /etc/systemd/system/mta-sa.service <<'EOF'
[Unit]
Description=MTA:SA Server
After=network.target

[Service]
Type=simple
WorkingDirectory=/srv/mta
ExecStart=/srv/mta/mta-server64
Restart=always
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now mta-sa

sleep 3
systemctl status mta-sa --no-pager || true

echo "[MTA] MTA:SA server installation complete."
echo "[MTA] Service name: mta-sa"
echo "[MTA] Default server ports: 22003 TCP/UDP and related MTA game ports."
echo "[MTA] Edit the config files under /srv/mta/mods/deathmatch/ and restart the service when needed."
