#IAM ROLES FOR EKS AND NODES
resource "aws_iam_role" "EKSClusterRole" {
  name = "EKSClusterRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "NodeGroupRole" {
  name = "EKSNodeGroupRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.EKSClusterRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.NodeGroupRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.NodeGroupRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.NodeGroupRole.name
}

#EKS

resource "aws_eks_cluster" "eks-cluster" {
  name     = "eks-cluster"
  role_arn = aws_iam_role.EKSClusterRole.arn
  version  = "1.24"

  vpc_config {
    subnet_ids          = flatten([ var.public_subnets_id, var.private_subnets_id ])
    security_group_ids  = flatten(var.security_groups_id)
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
  ]
}

 # NODE 
resource "aws_eks_node_group" "node-ec2" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "t3_micro-node_group"
  node_role_arn   = aws_iam_role.NodeGroupRole.arn
  subnet_ids      = flatten(  var.private_subnets_id )
  
    launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  ami_type       = "AL2_x86_64"
  # instance_types = ["t3.micro"]
  capacity_type  = "ON_DEMAND"
  # disk_size      = 10

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy
  ]
}



resource "aws_launch_template" "launch_template" {
  name = "ltemp"
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 10
    }
  }
  # image_id                             = var.ami
  # instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "t3.micro"
  network_interfaces {
    device_index                = 0
    associate_public_ip_address = true
    security_groups             = [var.security_group_id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "instance-lt-"
    }
  }
  # user_data = filebase64("${path.module}/script.sh")
}









































# ################################################################################################
# # EKS
# ################################################################################################

# resource "aws_eks_cluster" "eks" {
#   name     = "example"
#   role_arn = aws_iam_role.eks_role.arn
#   version = "1.24"

#   vpc_config {
#     subnet_ids = var.subnet_ids
#     endpoint_private_access = true
#     endpoint_public_access  = true
#     public_access_cidrs     = ["0.0.0.0/0"]
#     security_group_ids      = [aws_security_group.eks_cluster.id, aws_security_group.eks_nodes.id]
#   }

#   # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
#   # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
#   depends_on = [
#     aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
#     aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
#   ]
# }


# ##################################################################################################
# # IAM ROLE FOR EKS
# ################################################################################################

# resource "aws_iam_role" "eks_role" {
#   name = "eks-cluster-example"

#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "eks.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# POLICY
# }

# resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.eks_role.name
# }

# # Optionally, enable Security Groups for Pods
# # Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
# resource "aws_iam_role_policy_attachment" "example-AmazonEKSVPCResourceController" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
#   role       = aws_iam_role.eks_role.name
# }

# ################################################################################################
# # NODE GROUP 
# ################################################################################################

# resource "aws_eks_node_group" "node_gpoup" {
#   cluster_name    = aws_eks_cluster.eks.name
#   node_group_name = "node"
#   node_role_arn   = aws_iam_role.node_role.arn
#   subnet_ids      = var.private_subnet_ids
 

#   launch_template {
#     id      = var.launch_template
#     version = "$Latest"
#   }

#   scaling_config {
#     desired_size = 1
#     max_size     = 2
#     min_size     = 1
#   }

#   update_config {
#     max_unavailable = 1
#   }

#   # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
#   # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
#   depends_on = [
#     aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
#   ]
# }
# resource "aws_iam_role" "node_role" {
#   name = "eks-node-group-example"

#   assume_role_policy = jsonencode({
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#     }]
#     Version = "2012-10-17"
#   })
# }

# resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.node_role.name
# }

# resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.node_role.name
# }

# resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.node_role.name
# }



# ##############################################
# # EKS Cluster Security Group
# resource "aws_security_group" "eks_cluster" {
#   name        = "-cluster-sg"
#   description = "Cluster communication with worker nodes"
#   vpc_id      = var.vpc_id

#   tags = {
#     Name = "-cluster-sg"
#   }
# }

# resource "aws_security_group_rule" "cluster_inbound" {
#   description              = "Allow worker nodes to communicate with the cluster API Server"
#   from_port                = 443
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.eks_cluster.id
#   source_security_group_id = aws_security_group.eks_nodes.id
#   to_port                  = 443
#   type                     = "ingress"
# }

# resource "aws_security_group_rule" "cluster_outbound" {
#   description              = "Allow cluster API Server to communicate with the worker nodes"
#   from_port                = 1024
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.eks_cluster.id
#   source_security_group_id = aws_security_group.eks_nodes.id
#   to_port                  = 65535
#   type                     = "egress"
# }

# ##########################################

# resource "aws_security_group" "eks_nodes" {
#   name        = "node-sg"
#   description = "Security group for all nodes in the cluster"
#   vpc_id      = var.vpc_id

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name                                           = "node-sg"
#     "kubernetes.io/cluster/cluster" = "owned"
#   }
# }

# resource "aws_security_group_rule" "nodes_internal" {
#   description              = "Allow nodes to communicate with each other"
#   from_port                = 0
#   protocol                 = "-1"
#   security_group_id        = aws_security_group.eks_nodes.id
#   source_security_group_id = aws_security_group.eks_nodes.id
#   to_port                  = 65535
#   type                     = "ingress"
# }

# resource "aws_security_group_rule" "nodes_cluster_inbound" {
#   description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
#   from_port                = 1025
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.eks_nodes.id
#   source_security_group_id = aws_security_group.eks_cluster.id
#   to_port                  = 65535
#   type                     = "ingress"
# }








# output "cluster_name" {
#   value = aws_eks_cluster.eks.name
# }

# output "cluster_endpoint" {
#   value = aws_eks_cluster.eks.endpoint
# }

# output "cluster_ca_certificate" {
#   value = aws_eks_cluster.eks.certificate_authority[0].data
# }