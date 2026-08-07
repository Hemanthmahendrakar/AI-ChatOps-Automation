resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
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
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone
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
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


resource "aws_security_group" "ai_servers" {
  name        = "${var.project_name}-security-group"
  description = "Security group for AI servers"
  vpc_id      = aws_vpc.main.id


  ingress {
    description = "SSH access"
    from_port   = 22
    to_port    = 22
    protocol   = "tcp"

    cidr_blocks = [
      var.my_ip
    ]
  }


  ingress {
    description = "Open WebUI"
    from_port   = 3000
    to_port    = 3000
    protocol   = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }


  ingress {
    description = "Ollama API"
    from_port   = 11434
    to_port    = 11434
    protocol   = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }


  egress {
    from_port   = 0
    to_port    = 0
    protocol   = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }


  tags = {
    Name = "${var.project_name}-sg"
  }
}


resource "aws_instance" "openwebui" {

  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ai_servers.id]
  associate_public_ip_address = true

  key_name = "devops"


  root_block_device {
    volume_size = 20
    volume_type = "gp3"

    delete_on_termination = true

    tags = {
      Name = "${var.project_name}-openwebui-root-volume"
    }
  }


  tags = {
    Name = "openwebui-server"
  }
}



resource "aws_instance" "ollama" {

  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ai_servers.id]
  associate_public_ip_address = true

  key_name = "devops"


  root_block_device {
    volume_size = 20
    volume_type = "gp3"

    delete_on_termination = true

    tags = {
      Name = "${var.project_name}-ollama-root-volume"
    }
  }


  tags = {
    Name = "ollama-server"
  }
}
