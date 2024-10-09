data "aws_ami" "example" {
  most_recent = true
  owners      = ["amazon"]
  tags = {
    Name = "terraform-jenkins-eks"
  }

  filter {
    name   = "name"
  #  values = ["amzn2-ami-kernel-*-hvm-*-x86_64-gp2"]
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_availability_zones" "azs" {}