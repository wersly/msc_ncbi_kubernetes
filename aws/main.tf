provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.1.0"

  name = "EKS-test-vpc"
  cidr = var.vpc_cidr

  azs = var.vpc_azs
  public_subnets = var.vpc_public_subnets

  enable_nat_gateway = false
  enable_dns_hostnames = true

  vpc_tags = {
    Name = "msc-eks-vpc"
  }
}


resource "aws_security_group" "public_eks_service" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}


data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.1.0"

  cluster_name = "msc-test-eks"
  cluster_version = "1.20"
  subnets = module.vpc.public_subnets
  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      name = "worker-group-1"
      instance_type = "t2.micro"
      asg_max_size = 1
    },
    {
      name = "worker-group-2"
      instance_type = "t2.micro"
      asg_max_size = 1
    },
    {
      name = "worker-group-3"
      instance_type = "t2.micro"
      asg_max_size = 1
    }
  ]

  map_users = var.eks_map_users
  map_accounts = var.eks_map_accounts
}

