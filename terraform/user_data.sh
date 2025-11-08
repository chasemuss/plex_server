#!/bin/bash
# User data script for auto-setup (excluding claim).
# Updated: 2025 — reliable Plex install, S3 mount, validation.

set -euo pipefail
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "=== Starting user-data setup ==="

apt update -y
apt install -y curl wget jq fuse awscli libusb-1.0-0

echo "Installing Plex Media Server via .deb..."
PLEX_URL=$(curl -s https://plex.tv/api/downloads/5.json | \
  jq -r '.computer.Linux.releases[] | select(.distro=="ubuntu" and .build=="linux-x86_64") | .url')
wget -q "$PLEX_URL" -O /tmp/plex.deb
dpkg -i /tmp/plex.deb || apt-get install -f -y
rm -f /tmp/plex.deb

systemctl enable plexmediaserver
systemctl start plexmediaserver

echo "Waiting for Plex to start on :32400..."
timeout 120 bash -c 'until curl -s http://localhost:32400 > /dev/null; do sleep 5; done' || \
  echo "Plex failed to start in 120s"

apt install -y s3fs
echo "user_allow_other" > /etc/fuse.conf

mkdir -p /media

for i in {1..5}; do
  s3fs chasemuss-plex:/media /media \
    -o iam_role=auto \
    -o allow_other \
    -o use_cache=/tmp \
    -o uid=$(id -u plex) \
    -o gid=$(id -g plex) \
    -o umask=0022 \
    -o mp_umask=0022 && break
  echo "S3 mount failed, retry $i..."
  sleep 10
done

if ! mountpoint -q /media; then
  echo "ERROR: Failed to mount S3"
  exit 1
fi

echo "S3 mounted at /media"

aws s3 cp s3://chasemuss-plex/scripts/validate.sh /home/ubuntu/validate.sh
chmod +x /home/ubuntu/validate.sh
chown ubuntu:ubuntu /home/ubuntu/validate.sh

echo "=== Setup complete. Run: sudo /home/ubuntu/validate.sh ==="