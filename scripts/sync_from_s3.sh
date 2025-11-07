#!/bin/bash
# Sync latest media from S3 to EC2
aws s3 sync s3://chasemuss-plex/media/ /mnt/plex-media/ --delete
chown -R plex:plex /mnt/plex-media/