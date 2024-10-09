terraform {
  backend "s3" {
    bucket = "cicd-terraform-eks-xyz"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}