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

  # Cluster Management (port 9997)
  ingress {
    from_port   = 9997
    to_port     = 9997
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Cluster Management (port 8080)
  ingress {
    from_port   = 8080
    to_port     = 8080
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

# Create IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2_describe_tags_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "describe_tags_policy" {
  name = "describe_tags_policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ec2:DescribeTags"]
      Resource = "*"
    }]
  })
}

# Create IAM Instance Profile for the role
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}


# Create 4 EC2 instances of type c5.4xlarge
resource "aws_instance" "large_instances" {
  count         = 4
  ami           = var.ami_id
  instance_type = "c5.4xlarge"
  key_name      = var.pem_key_name
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.splunk_sg.id]
  
  # Attach the IAM instance profile here
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name                           = var.large_instance_names[count.index]
    workshop                       = "itsi-practical-lab"
    splunkit_golden_ami            = "true"
    splunkit_data_classification   = "public"
  }

  root_block_device {
    volume_size = 100
  }

  # Assign the EC2 Instance Name as the hostname to make it easier to identify
  user_data = <<-EOF
            #!/bin/bash
            HOSTNAME="${var.large_instance_names[count.index]}"
            hostnamectl set-hostname $HOSTNAME
            echo "127.0.0.1   $HOSTNAME" >> /etc/hosts
            EOF

}

# Create 2 EC2 instances of type t2.medium
resource "aws_instance" "medium_instances" {
  count         = 2
  ami           = var.ami_id
  instance_type = "t2.medium"
  key_name      = var.pem_key_name
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.splunk_sg.id]

    
  # Attach the IAM instance profile here
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name                           = var.medium_instance_names[count.index]
    workshop                       = "itsi-practical-lab"
    splunkit_golden_ami            = "true"
    splunkit_data_classification   = "public"
  }

  # Assign the EC2 Instance Name as the hostname to make it easier to identify
  user_data = <<-EOF
            #!/bin/bash
            HOSTNAME="${var.medium_instance_names[count.index]}"
            hostnamectl set-hostname $HOSTNAME
            echo "127.0.0.1   $HOSTNAME" >> /etc/hosts
            EOF

}
