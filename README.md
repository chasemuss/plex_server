# plex_server
IaC and associated code for my Plex Server

```tree
plex-aws/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── vpc.tf
│   ├── ec2.tf
│   ├── s3.tf
│   └── locals.tf
├── scripts/
│   ├── upload_media.py
│   └── sync_from_s3.sh
├── .github/workflows/
│   └── deploy.yml
├── README.md
└── terraform.tfvars.example
```