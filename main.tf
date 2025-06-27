provider "aws" {
  region = var.region
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "splunkit-vpc"

  }
}

# Create Subnet
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "splunkit-subnet"
    workshop = "itsi-practical-lab"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "splunkit-internet-gateway"
    workshop = "itsi-practical-lab"
  }
}

# Create Route Table and Associate with Subnet
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "splunkit-route-table"
    workshop = "itsi-practical-lab"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# Create Security Group
resource "aws_security_group" "splunk_sg" {
  vpc_id = aws_vpc.main.id
  name   = "splunk-security-group"

  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Splunk Web access (port 8000)
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Splunk Management port (port 8089)
  ingress {
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "splunk-security-group"
    workshop = "itsi-practical-lab"
  }
}

# Create 4 EC2 instances of type c5.4xlarge
resource "aws_instance" "large_instances" {
  count         = 4
  ami           = var.ami_id
  instance_type = "c5.4xlarge"
  key_name      = var.pem_key_name
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.splunk_sg.id]

  tags = {
    Name                           = var.large_instance_names[count.index]
    workshop                       = "itsi-practical-lab"
    splunkit_golden_ami            = "true"
    splunkit_data_classification   = "public"
  }

  root_block_device {
    volume_size = 100
  }
}

# Create 2 EC2 instances of type t2.medium
resource "aws_instance" "medium_instances" {
  count         = 2
  ami           = var.ami_id
  instance_type = "t2.medium"
  key_name      = var.pem_key_name
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.splunk_sg.id]

  tags = {
    Name                           = var.medium_instance_names[count.index]
    workshop                       = "itsi-practical-lab"
    splunkit_golden_ami            = "true"
    splunkit_data_classification   = "public"
  }
}