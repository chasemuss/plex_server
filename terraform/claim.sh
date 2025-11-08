#!/bin/bash
# Manual claim script for Plex.
# Justification: Extracted from user_data for manual execution to avoid boot-time issues (e.g., timing, network). Takes token as $1 for security.

if [ -z "$1" ]; then
  echo "Usage: bash claim.sh <plex_claim_token>"
  exit 1
fi

TOKEN=$1

# Ensure Plex is running.
systemctl start plexmediaserver
sleep 30  # Wait for service up.

MACHINE_ID=$(curl -s 'http://127.0.0.1:32400/identity' | grep -oP 'MachineIdentifier="\K[^"]+')
VERSION=$(dpkg -s plexmediaserver | grep Version | cut -d ' ' -f2)

CLAIM_RESPONSE=$(curl -X POST "https://plex.tv/api/claim/exchange?token=$TOKEN" \
  -H "X-Plex-Product: Plex Media Server" \
  -H "X-Plex-Version: $VERSION" \
  -H "X-Plex-Client-Identifier: $MACHINE_ID" \
  -H "X-Plex-Provides: server" \
  -H "X-Plex-Platform: Linux" \
  -H "X-Plex-Platform-Version: $(uname -r)" \
  -H "X-Plex-Device-Name: $(hostname)")

AUTH_TOKEN=$(echo $CLAIM_RESPONSE | grep -oP 'authToken="\K[^"]+')

# Update Preferences.xml.
PREFS="/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Preferences.xml"
if [ -f "$PREFS" ]; then
  sed -i "s/PlexOnlineToken=\"[^\"]*\"/PlexOnlineToken=\"$AUTH_TOKEN\"/g" $PREFS
else
  echo "<?xml version=\"1.0\" encoding=\"utf-8\"?><Preferences PlexOnlineToken=\"$AUTH_TOKEN\"/>" > $PREFS
fi

systemctl restart plexmediaserver
echo "Plex server claimed successfully."