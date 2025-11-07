#!/bin/bash
set -e

S3_BUCKET="${s3_bucket}"
AWS_REGION="${aws_region}"
DEVICE="/dev/nvme1n1"
MOUNT="/mnt/plex-media"
PLEX_CLAIM_TOKEN="${plex_claim_token}"  # Passed from Terraform

if ! grep -qs "$MOUNT" /proc/mounts; then
  mkfs.ext4 $DEVICE
  mkdir -p $MOUNT
  mount $DEVICE $MOUNT
  echo "$DEVICE $MOUNT ext4 defaults,nofail 0 2" >> /etc/fstab
fi

# Install Plex
curl https://downloads.plex.tv/plex-keys/PlexSign.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/plex.gpg >/dev/null
echo "deb https://downloads.plex.tv/repo/deb public main" > /etc/apt/sources.list.d/plexmediaserver.list
apt update && apt install -y plexmediaserver

# Auto-claim server
if [ -n "$PLEX_CLAIM_TOKEN" ]; then
  mkdir -p /var/lib/plexmediaserver/Library/Application\ Support/Plex\ Media\ Server/
  echo "PlexClaimToken=$PLEX_CLAIM_TOKEN" > /var/lib/plexmediaserver/Library/Application\ Support/Plex\ Media\ Server/Preferences.xml
  chown -R plex:plex /var/lib/plexmediaserver/
fi

# Set media library path
sed -i 's|/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/|/mnt/plex-media|' /etc/default/plexmediaserver

# Sync media from S3 on boot
aws s3 sync s3://$S3_BUCKET/media/ $MOUNT/ --region $AWS_REGION || echo "Initial sync failed or no media"

# Start Plex
systemctl enable plexmediaserver
systemctl start plexmediaserver