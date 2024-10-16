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
    key    = "prod/vpc.tfstate"
    region = "us-west-1"
    profile = "loyal-devops-west-1"
  }
}

provider "aws" {
  region  = "us-west-1"
  profile = "loyal-devops-west-1"
  shared_credentials_files = ["~/.aws/credentials"]
}

resource "aws_vpc" "prebid_server_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "prebid_server_vpc"
    Env = "production"
  }
}

# Subnets
resource "aws_subnet" "prebid_server_public_a" {
  # Public subnet is for the bastion host
  vpc_id                  = aws_vpc.prebid_server_vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-west-1a"
}

resource "aws_subnet" "prebid_server_public_b" {
  # Public subnet is for the bastion host
  vpc_id                  = aws_vpc.prebid_server_vpc.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-west-1b"
}

resource "aws_subnet" "prebid_server_subnet_1" {
  # TODO: Rename to Private
  vpc_id            = aws_vpc.prebid_server_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-1a"

  tags = {
    Name = "prebid_server_subnet_1"
    Env = "production"
  }
}

resource "aws_subnet" "prebid_server_subnet_2" {
  vpc_id            = aws_vpc.prebid_server_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-1b"

  tags = {
    Name = "prebid_server_subnet_2"
    Env = "production"
  }
}
