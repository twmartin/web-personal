terraform {
  backend "s3" {
    bucket = "twmartin-terraform-backend"
    key    = "twmartin-codes.tfstate"
    region = "us-east-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "twmartin_codes_s3_bucket" {
  bucket = "twmartin.codes"
  website {
    index_document = "index.html"
  }
  logging {
    target_bucket = "twmartin-s3-access-logs-us-east-2"
    target_prefix = "twmartin.codes"
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CloudflareGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::twmartin.codes/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": [
            "103.21.244.0/22",
            "103.22.200.0/22",
            "103.31.4.0/22",
            "104.16.0.0/12",
            "108.162.192.0/18",
            "131.0.72.0/22",
            "141.101.64.0/18",
            "162.158.0.0/15",
            "172.64.0.0/13",
            "173.245.48.0/20",
            "188.114.96.0/20",
            "190.93.240.0/20",
            "197.234.240.0/22",
            "198.41.128.0/17",
            "2400:cb00::/32",
            "2405:8100::/32",
            "2405:b500::/32",
            "2606:4700::/32",
            "2803:f800::/32",
            "2a06:98c0::/29",
            "2c0f:f248::/32"
          ]
        }
      }
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "www_twmartin_codes_s3_bucket" {
  bucket = "www.twmartin.codes"
  website {
    redirect_all_requests_to = "https://twmartin.codes"
  }
  logging {
    target_bucket = "twmartin-s3-access-logs-us-east-2"
    target_prefix = "www.twmartin.codes"
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_iam_role" "codebuild_twmartin_codes_iam_role" {
  name               = "codebuild-twmartin.codes-iam-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_twmartin_codes_iam_policy" {
  role = aws_iam_role.codebuild_twmartin_codes_iam_role.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "${aws_s3_bucket.twmartin_codes_s3_bucket.arn}",
        "${aws_s3_bucket.twmartin_codes_s3_bucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "codebuild_twmartin_codes" {
  name          = "twmartin_codes"
  description   = "Builds twmartin.codes and pushes to s3"
  badge_enabled = true
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_twmartin_codes_iam_role.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:4.0"
    type         = "LINUX_CONTAINER"
  }
  source {
    type            = "GITHUB"
    location        = "https://github.com/twmartin/web-personal.git"
    git_clone_depth = 1
  }
}

# Sets the script with the name "script_1"
resource "cloudflare_worker_script" "http_headers_workers_script" {
  name    = "http-headers"
  content = file("http-headers-workers-script.js")
}

resource "cloudflare_worker_route" "twmartin_codes_http_headers_route" {
  zone_id     = "ec1a60c135b8f65669669e4223132c8f"
  pattern     = "twmartin.codes/*"
  script_name = cloudflare_worker_script.http_headers_workers_script.name
}
