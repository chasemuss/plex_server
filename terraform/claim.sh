#!/bin/bash
# Simple manual Plex claim script

# Prompt for claim token
read -p "Enter Plex claim token (from https://plex.tv/claim): " TOKEN
if [[ -z "$TOKEN" ]]; then
  echo "No token entered. Exiting."
  exit 1
fi

# Start Plex
systemctl start plexmediaserver.service
sleep 15

# Claim server
curl -X POST \
  -H "Content-Type: application/json" \
  -d "{\"token\": \"$TOKEN\"}" \
  http://localhost:32400/myplex/claim

# Restart
systemctl restart plexmediaserver.service

echo "Done! Open: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):32400/web"