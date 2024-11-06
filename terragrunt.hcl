locals {
  region = "us-west-1"
  environment = "dev"
  state_bucket = "terragrunt-gitlab-runner-s3-bucket"
  state_dynamodb_table = "terragrunt-gitlab-runner-dynamodb-table"

  ami = "ami-0cf4e1fcfd8494d5b"
  instance_type = "t2.small"
  key_name = "terragrunt-key"

  gitlab_url = "https://gitlab.com"
  gitlab_token = "glrt-t3_sEKxCLNeuZFp2Tsh7UnX"
  gitlab_tags = "asif"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = local.state_bucket
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = local.state_dynamodb_table
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.region}"
}
EOF
}
