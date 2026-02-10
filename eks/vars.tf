variable "aws_access_key" {
  type = string
  sensitive = true
}

variable "aws_secret_key" {
  type = string
  sensitive = true
}

variable "aws_region" {
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "환경 (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "프로젝트 이름"
  type        = string
  default     = "eks-optimizer"
}

variable "cluster_version" {
  description = "EKS 클러스터 버전"
  type        = string
  default     = "1.28"
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
  default     = "10.0.0.0/16"
}

variable "node_instance_types" {
  description = "EKS 노드 인스턴스 타입"
  type        = list(string)
  default     = ["t3.micro"]
}

variable "node_desired_size" {
  description = "노드 그룹 desired 사이즈"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "노드 그룹 최소 사이즈"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "노드 그룹 최대 사이즈"
  type        = number
  default     = 4
}
