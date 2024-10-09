terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.66"
    }
  }
}

# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc"
  cidr = var.vpc_cidr

  azs            = data.aws_availability_zones.azs.names
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_dns_hostnames = true

  tags = {
    name        = "jenkins-vpc"
    Terraform   = "true"
    Environment = "dev"
  }

  public_subnet_tags = {
    Name = "jenkins-subnet"
  }
}

# SG
module "sg" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "jenkins-sg"
  description = "Security Group for Jenkins Server"

  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    name = "jenkins-sg"
  }
}

# EC2
module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"
  name   = "jenkins-ec2-Server"

  instance_type               = var.instance_type
  key_name                    = "default-ec2-us-east-1"
  monitoring                  = true
  vpc_security_group_ids      = [module.sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  user_data                   = file("jenkins-install.sh")
  availability_zone           = data.aws_availability_zones.azs.names[0]


  tags = {
    name        = "jenkins-ec2-Server"
    Terraform   = "true"
    Environment = "dev"
  }
}


# S3 bucket
resource "aws_s3_bucket" "jenkins_s3_bucket" {
  bucket = "cicd-terraform-eks-xyz"
}

resource "aws_s3_bucket_versioning" "jenkins_s3_versioning" {
  bucket = aws_s3_bucket.jenkins_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

