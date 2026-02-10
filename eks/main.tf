locals {
  name = "${var.project_name}-${var.environment}"
  cluster_name = "${local.name}-cluster"
  
  tags = {
    Project = var.project_name
  }
}


# VPC 구성
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name}-vpc"
  cidr = var.vpc_cidr

  azs = ["${var.aws_region}a", "${var.aws_region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true 
  enable_dns_hostnames = true
  enable_dns_support = true

  # EKS 필수 태그
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  tags = local.tags
}


# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  create_kms_key = false
  cluster_encryption_config = {}


  # EKS Managed Node Group
  eks_managed_node_groups = {
    main = {
      name = "${local.name}-ng"

      instance_types = var.node_instance_types
      ami_type = "AL2_x86_64"

      min_size = var.node_min_size
      max_size = var.node_max_size
      desired_size = var.node_desired_size

      tags = merge(
        local.tags,
        {
          Name = "${local.name}-node"
        }
      )
    }
  }

  # 클러스터 보안 그룹 추가 규칙
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description = "Nodes on ephemeral ports"
      protocol = "tcp"
      from_port = 1025
      to_port = 65535
      type = "ingress"
      source_node_security_group = true
    }
  }

  # 노드 보안 그룹 추가 규칙
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol = "-1"
      from_port = 0
      to_port = 0
      type = "ingress"
      self = true
    }
    
    # Prometheus 메트릭 수집을 위한 포트
    ingress_prometheus = {
      description = "Prometheus metrics"
      protocol = "tcp"
      from_port = 9090
      to_port = 9090
      type = "ingress"
      self = true
    }
  }

  tags = local.tags
}
