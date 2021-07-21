terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  # canada
  region = "ca-central-1"
  default_tags {
    tags = {
      project = "olympics_vpn"
    }
  }
}

locals {
  # yeah, just hardcoding, getting things done, down and dirty
  cidr_block = "10.0.0.0/24"
}

resource "aws_vpc" "this" {
  cidr_block = local.cidr_block
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.this.id
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "primary" {
  vpc_id     = aws_vpc.this.id
  cidr_block = local.cidr_block
  # again, if someone was paying me, I'd be less caviler
  availability_zone = data.aws_availability_zones.available.names[0]
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.nano"
}
