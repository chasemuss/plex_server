#!/bin/bash
# User data script for auto-setup (excluding claim).
# Justification: Automates base install and S3 mount for reliability. Claim moved to manual script to resolve boot issues.

apt update -y
apt install -y curl apt-transport-https fuse awscli

# Install Plex.
curl https://downloads.plex.tv/plex-keys/PlexSign.key | apt-key add -
echo "deb https://downloads.plex.tv/repo/deb public main" | tee /etc/apt/sources.list.d/plexmediaserver.list
apt update -y
apt install -y plexmediaserver

# Enable and start Plex.
systemctl enable plexmediaserver
systemctl start plexmediaserver

# Install s3fs.
apt install -y s3fs

# Mount S3 with prefix for media.
mkdir /media
s3fs chasemuss-plex:/media /media -o iam_role=auto -o allow_other -o use_cache=/tmp -o uid=$(id -u plex) -o gid=$(id -g plex) -o umask=0022

# Copy claim script from S3.
aws s3 cp s3://chasemuss-plex/scripts/claim.sh /home/ubuntu/claim.sh
chmod +x /home/ubuntu/claim.sh
chown ubuntu:ubuntu /home/ubuntu/claim.sh