data "aws_ami" "nixos" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  owners = ["080433136561"] # NixOS
}


# todo: for debugging
module "key" {
  source      = "git@github.com:KyleOndy/terraform-aws-local-keypair.git?ref=v0.1.0"
  name_prefix = "scratch"
}

output "key_name" {
  value = module.key.name
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

resource "aws_instance" "ec2_redirect" {
  ami = data.aws_ami.nixos.id
  # a t4g.nano was OOM when running `nixos-rebuild switch`
  instance_type = "t4g.micro"
  key_name      = module.key.name
  subnet_id     = module.dynamic_subnets.public_subnet_ids[0] # todo: random
  vpc_security_group_ids = [
    aws_security_group.allow_all_egress.id,
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_http_ingress.id,
  ]

  root_block_device {
    volume_size = "20"
  }

  # todo: once I get a handle on usage, maybe make this unlimited.
  credit_specification {
    cpu_credits = "standard"
  }

  # todo: YIKES! Holy path. This will fall out when refactored into a module
  user_data_base64 = filebase64("${path.module}/../nodes/ec2_redirect/configuration.nix")
}

output "ec2_ip" {
  value = aws_instance.ec2_redirect.public_ip
}

module "myip" {
  source  = "4ops/myip/http"
  version = "1.0.0"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound connections"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${module.myip.address}/32"]
  }
}

resource "aws_security_group" "allow_all_egress" {
  name        = "allow_all_egress"
  description = "Allow all outgoing conncetions"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "allow_http_ingress" {
  name        = "allow_http_ingress"
  description = "allow http(s) ingress"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

module "vpc" {
  source     = "cloudposse/vpc/aws"
  version    = "0.25.0"
  cidr_block = "10.0.0.0/16"
}

module "dynamic_subnets" {
  source             = "cloudposse/dynamic-subnets/aws"
  version            = "0.39.0"
  availability_zones = [data.aws_availability_zones.available.names[0]]
  vpc_id             = module.vpc.vpc_id
  igw_id             = module.vpc.igw_id
  cidr_block         = "10.0.0.0/16"
}

data "aws_availability_zones" "available" {
  state = "available"
}

output "ec2_dns" {
  value = aws_instance.ec2_redirect.public_dns
}
