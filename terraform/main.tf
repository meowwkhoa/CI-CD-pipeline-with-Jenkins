# To define that we will use AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0" // Provider version
    }
  }
  required_version = ">= 1.5.6" // Terraform version
}

// The library with methods for creating and
// managing the infrastructure in AWS, this will
// apply to all the resources in the project
provider "aws" {
  region = var.region
}

// Amazon S3
# resource "aws_s3_bucket" "static" {
#   bucket = var.bucket
#   acl    = "private"
# }

// Amazon EC2
# resource "aws_instance" "vm_instance" {
#   ami           = "ami-0c55b159cbfafe1f0" // Ubuntu Server 22.04 LTS
#   instance_type = "t2.micro"

#   tags = {
#     Name = "terraform-instance"
#   }
# }

// Amazon EKS
resource "aws_eks_cluster" "primary" {
  name     = "${var.project_id}-eks"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = aws_subnet.eks_subnet[*].id
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project_id}-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "eks_subnet" {
  count             = 2
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
}

data "aws_availability_zones" "available" {}