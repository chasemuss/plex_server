# File: user_data.sh
# Purpose: Bootstrap script to install Plex, mount S3 as /plex-media, and configure auto-start.
#          Uses s3fs for simplicity; goofys is faster but more complex.

#!/bin/bash
set -e

# Update system
dnf update -y
dnf install -y amazon-linux-extras

# Install Plex Media Server
curl https://downloads.plex.tv/plex-media-server-new/$(curl -s https://plex.tv/api/downloads/5.json | jq -r '.computer.Linux.releases[] | select(.distro=="amazon" and .build=="linux-aarch64") | .url') --output plex.rpm
dnf localinstall -y plex.rpm

# Install s3fs to mount S3 bucket
dnf install -y fuse s3fs

# Create mount point
mkdir -p /plex-media
mkdir -p /plex-config

# Configure s3fs (credentials via IAM role)
echo "${s3_bucket} /plex-media fuse.s3fs _netdev,allow_other,umask=000,uid=1000,gid=1000 0 0" >> /etc/fstab

# Mount S3
mount -a

# Move Plex metadata to EBS (faster access)
systemctl stop plexmediaserver
mv /var/lib/plexmediaserver /plex-config/
ln -s /plex-config/plexmediaserver /var/lib/plexmediaserver
systemctl start plexmediaserver

# Enable services
systemctl enable plexmediaserver
systemctl enable s3fs.mount

# Create media library path
mkdir -p /plex-media/movies
mkdir -p /plex-media/tv

echo "Plex setup complete. Access at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):32400/web" 