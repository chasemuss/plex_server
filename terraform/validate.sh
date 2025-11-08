#!/bin/bash
# validate.sh - Run manually after boot to verify setup

set -euo pipefail

echo "=== Plex & S3 Validation ==="

if ! systemctl is-active --quiet plexmediaserver; then
  echo "Plex service is NOT running"
  exit 1
fi
echo "Plex service: RUNNING"

if ! ss -tlnp | grep -q 32400; then
  echo "Port 32400 NOT open"
  exit 1
fi
echo "Port 32400: LISTENING"

if ! curl -s http://localhost:32400/identity > /dev/null; then
  echo "Plex web UI NOT responding"
  exit 1
fi
echo "Plex web UI: RESPONDING"

if ! mountpoint -q /media; then
  echo "S3 NOT mounted at /media"
  exit 1
fi
echo "S3: MOUNTED at /media"

if ! su - plex -c "test -r /media && test -w /media"; then
  echo "plex user cannot access /media"
  exit 1
fi
echo "plex user: CAN access /media"

PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 || echo "UNKNOWN")
echo "Public IP: $PUBLIC_IP"
echo "Access Plex at: http://$PUBLIC_IP:32400/web"

echo "ALL CHECKS PASSED. Ready for manual claim."