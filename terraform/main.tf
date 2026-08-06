resource "aws_vpc" "main" {

  cidr_block = var.vpc_cidr

  enable_dns_support = true

  enable_dns_hostnames = true


  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "main" {

  vpc_id = aws_vpc.main.id


  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_subnet" "public" {

  vpc_id = aws_vpc.main.id

  cidr_block = var.subnet_cidr

  availability_zone = var.availability_zone


  map_public_ip_on_launch = true


  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}


resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main.id


  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.main.id

  }


  tags = {
    Name = "${var.project_name}-route-table"
  }
}

resource "aws_route_table_association" "public" {

  subnet_id = aws_subnet.public.id

  route_table_id = aws_route_table.public.id

}

resource "aws_security_group" "ai_servers" {

  name = "${var.project_name}-security-group"

  description = "Security group for AI servers"

  vpc_id = aws_vpc.main.id


  ingress {

    description = "SSH"

    from_port = 22

    to_port = 22

    protocol = "tcp"

    cidr_blocks = [
      var.my_ip
    ]

  }


  ingress {

    description = "Open WebUI"

    from_port = 3000

    to_port = 3000

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]

  }


  ingress {

    description = "Ollama API"

    from_port = 11434

    to_port = 11434

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]

  }


  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]

  }


  tags = {

    Name = "${var.project_name}-sg"

  }

}


resource "tls_private_key" "ssh_key" {

  algorithm = "RSA"

  rsa_bits = 4096

}


resource "aws_key_pair" "ai_key" {

  key_name = "${var.project_name}-key"

  public_key = tls_private_key.ssh_key.public_key_openssh

}


resource "local_file" "private_key" {

  content = tls_private_key.ssh_key.private_key_pem

  filename = "${path.module}/ai-server-key.pem"

  file_permission = "0400"

}

variable "instance_type" {

  description = "EC2 instance size"

  type = string

}

resource "aws_instance" "openwebui" {

  ami = var.ami_id

  instance_type = var.instance_type

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.ai_servers.id
  ]

  key_name = aws_key_pair.ai_key.key_name


  associate_public_ip_address = true


  tags = {

    Name = "openwebui-server"

  }

}

resource "aws_instance" "ollama" {

  ami = var.ami_id

  instance_type = var.instance_type

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.ai_servers.id
  ]

  key_name = aws_key_pair.ai_key.key_name


  associate_public_ip_address = true


  tags = {

    Name = "ollama-server"

  }

}