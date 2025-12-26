resource "aws_key_pair" "eks" {
  key_name   = "eks"
  # you can paste the public key directly like this
  #public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL6ONJth+DzeXbU3oGATxjVmoRjPepdl7sBuPzzQT2Nc sivak@BOOK-I6CR3LQ85Q"
  //public_key = file("~/.ssh/eks.pub")
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCEwJ93NdRCmJHzEtdADrYl59Tp2L4ctkM2Y+K6EiVWM+oezCM74TnBmmH3H24PUv2gMNORP4F8m0qiGElJjGYwoHOjTL2NGW5e1fKkW21JWkhTp9CsVYt1KAdXNZ32rdhnXLo6VN7pIuS2G2snbxMTTCV6GhIHGnUH2FDyxMqrC8Jn4L7kkGGgcAmvycWUOHvQCCRhvo6oa7bnTqmJVxS31TpbMN+Hwm47yL11d/uAU9ZMLDv6O8UiEnKOIQmQUZLQHBqcHV2Sv6lAlo7G3aQ14mBisHZgI1C5D7WTIP8GpJAS71a0mmsgXl44OJ0OJKkZUjH97+EQ7oRJZHouGawGtAFjZ4MZxR1lQC6Ur/DPYrJvMSjZ7bz8qreve9qjlIrSXHOHnwtJucSRfEhx9PTFh+cy2Oxmry+8Kl2vC9bhUa9SNHGgm4OlYcfjKXABJRXeMTXnxR5IIPhZ/a0y5GPvXaCAqN3e1etSXsjwHtiLrJzWjgroKvRLHE3wZm4EFDmkf/qXS/6uVE9ktP2BAhz6cuhBbGd3u7HrFyoUwBdLMqgBS5E7oOHtarSyKg5EM1SzzUd2+LWNL4HV6PNa09hkBA2aqJ0GCElETPF38ZC4VfbphjuItPNrY42yTYdq9EHbYC95fHvWMOxsC7DieXeNQW8MImg70slJ979kryY/oQ== saiku@DESKTOP-JQEH3PL"
  # ~ means windows home directory
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"


  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = "1.31"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = data.aws_ssm_parameter.vpc_id.value
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  create_cluster_security_group = false
  cluster_security_group_id     = local.eks_control_plane_sg_id

  create_node_security_group = false
  node_security_group_id     = local.node_sg_id

  # the user which you used to create cluster will get admin access

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    # blue = {
    #   min_size      = 3
    #   max_size      = 10
    #   desired_size  = 3
    #   capacity_type = "SPOT"
    #   iam_role_additional_policies = {
    #     AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    #     AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
    #     ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    #   }
    #   # EKS takes AWS Linux 2 as it's OS to the nodes
    #   key_name = aws_key_pair.eks.key_name
    # }
    green = {
      min_size      = 3
      max_size      = 10
      desired_size  = 3
      capacity_type = "SPOT"
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
        ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }
      # EKS takes AWS Linux 2 as it's OS to the nodes
      key_name = aws_key_pair.eks.key_name
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  tags = var.common_tags
}  