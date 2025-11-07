#!/usr/bin/env python3
"""
Upload new media to S3 for Plex sync.
Run locally: python upload_media.py /path/to/media
"""

import os
import sys
import boto3
from pathlib import Path
from botocore.exceptions import NoCredentialsError

S3_BUCKET = "chasemuss-plex"
S3_PREFIX = "media/"

def upload_directory(local_path: str):
    if not os.path.isdir(local_path):
        print(f"Error: {local_path} is not a directory")
        sys.exit(1)

    s3 = boto3.client('s3')
    local_path = Path(local_path).resolve()

    print(f"Uploading {local_path} to s3://{S3_BUCKET}/{S3_PREFIX}")

    for root, _, files in os.walk(local_path):
        for file in files:
            local_file = Path(root) / file
            rel_path = local_file.relative_to(local_path)
            s3_key = f"{S3_PREFIX}{rel_path.as_posix()}"

            print(f"Uploading {local_file} → {s3_key}")
            try:
                s3.upload_file(str(local_file), S3_BUCKET, s3_key)
            except NoCredentialsError:
                print("AWS credentials not found!")
                sys.exit(1)
            except Exception as e:
                print(f"Failed {local_file}: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python upload_media.py <local_media_directory>")
        sys.exit(1)
    upload_directory(sys.argv[1])