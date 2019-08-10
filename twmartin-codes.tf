terraform {
  backend "s3" {
    bucket = "twmartin-terraform-backend"
    key = "twmartin-codes.tfstate"
    region = "us-east-2"
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
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::twmartin.codes/*"
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
  name = "codebuild-twmartin.codes-iam-role"
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
  role = "${aws_iam_role.codebuild_twmartin_codes_iam_role.name}"

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
  name = "twmartin_codes"
  description = "Builds twmartin.codes and pushes to s3"
  badge_enabled = true
  build_timeout = "5"
  service_role = "${aws_iam_role.codebuild_twmartin_codes_iam_role.arn}"
  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/standard:1.0"
    type = "LINUX_CONTAINER"
  }
  source {
    type = "GITHUB"
    location = "https://github.com/twmartin/web-personal.git"
    git_clone_depth = 1
  }
}
