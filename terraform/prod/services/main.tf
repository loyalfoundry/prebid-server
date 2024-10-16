terraform {
  required_providers {
    aws = { 
      source  = "hashicorp/aws"
      version = "~> 5.67"
    }   
  }
  required_version = ">= 1.9.6"

  backend "s3" {
    bucket = "terraform-state-prebid-server"
    key    = "prod/services/prebid.tfstate"
    region = "us-west-1"
    profile = "loyal-devops-west-1"
  }
}

provider "aws" {
  region  = "us-west-1"
  profile = "loyal-devops-west-1"
  shared_credentials_files = ["~/.aws/credentials"]
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket  = "terraform-state-prebid-server"
    key     = "prod/vpc.tfstate"
    region  = "us-west-1"
    profile = "loyal-devops-west-1"
  }
}
