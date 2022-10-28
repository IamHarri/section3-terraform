provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name = var.tag
  }
}

# 2 subnet
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${data.aws_region.current_region.name}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet1"
  }
}
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${data.aws_region.current_region.name}b"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet2"
  }
}
# interanet gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "dev-gw"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "dev-route-table"
  }
}
# association
resource "aws_route_table_association" "rt_association_subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_route_table_association" "rt_association_subnet2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt.id
}


# instance
data "template_file" "user_data" {
  template = file("./user_data/user_data.sh.tpl")
}
resource "aws_instance" "instance" {
  associate_public_ip_address = true
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.ec2_instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.subnet1.id
  vpc_security_group_ids      = [module.sg.id, module.sg1.id]
  user_data                   = data.template_file.user_data.rendered
  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }
  tags = {
    name = "dev-intance"
  }
}

# modules sg
module "sg" {
  source    = "./modules/sg"
  vpc_id    = aws_vpc.vpc.id
  from_port = 80
  to_port   = 80
  name = "allow http"
}

module "sg1" {
  source    = "./modules/sg"
  vpc_id    = aws_vpc.vpc.id
  from_port = 443
  to_port   = 443
  name = "allow https"
}