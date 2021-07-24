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
      Project = "olympics_vpn"
      Name    = "olympics_vpn"
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

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.primary.id
  route_table_id = aws_route_table.main.id
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

resource "aws_instance" "vpn" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.nano"
  key_name                    = module.key.name
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id,
    aws_security_group.vpn.id,
  ]
  subnet_id = aws_subnet.primary.id
  user_data_base64 = base64encode(templatefile(
    "${path.module}/userdata.tmpl",
    {

    }
  ))
}

resource "aws_security_group" "allow_ssh" {
  name_prefix = "allow_ssh:"
  description = "Allow SSH access from home"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH from home"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${module.myip.address}/32"]
  }
  ingress {
    description = "all from home"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["${module.myip.address}/32", "0.0.0.0/0"]
  }
}
resource "aws_security_group" "vpn" {
  name_prefix = "vpn:"
  description = "Allow VPN traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "VPN traffic into host"
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "myip" {
  source  = "4ops/myip/http"
  version = "1.0.0"
}

module "key" {
  source      = "git@github.com:KyleOndy/terraform-aws-local-keypair.git?ref=v0.1.0"
  name_prefix = "olympics_vpn:"
}

output "keypair" {
  value = module.key.filename
}

output "vpn_ip" {
  value = aws_instance.vpn.public_ip
}

data "aws_route53_zone" "ondy_org" {
  name = "ondy.org"
}

resource "aws_route53_record" "olympics_vpn" {
  zone_id = data.aws_route53_zone.ondy_org.zone_id
  name    = "ovpn.ondy.org"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.vpn.public_ip]
}

