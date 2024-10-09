data "aws_ami" "example" {
  most_recent = true
  owners      = ["amazon"]
  tags = {
    Name = "terraform-jenkins-eks"
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_availability_zones" "azs" {}