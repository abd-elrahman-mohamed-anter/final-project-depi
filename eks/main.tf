##########################
# Provider & AZs
##########################
provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

##########################
# VPC & Networking
##########################
resource "aws_vpc" "project_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = { Name = "project-vpc" }
}

resource "aws_subnet" "project_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.project_vpc.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = { Name = "project-subnet-${count.index}" }
}

resource "aws_internet_gateway" "project_igw" {
  vpc_id = aws_vpc.project_vpc.id

  tags = { Name = "project-igw" }
}

resource "aws_route_table" "project_route_table" {
  vpc_id = aws_vpc.project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project_igw.id
  }

  tags = { Name = "project-route-table" }
}

resource "aws_route_table_association" "a" {
  count          = 2
  subnet_id      = aws_subnet.project_subnet[count.index].id
  route_table_id = aws_route_table.project_route_table.id
}

##########################
# Security Groups
##########################
resource "aws_security_group" "project_cluster_sg" {
  vpc_id = aws_vpc.project_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "project-cluster-sg" }
}

resource "aws_security_group" "project_node_sg" {
  vpc_id = aws_vpc.project_vpc.id

  ingress {
    description = "Allow SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["156.221.20.201/32"]
  }

  ingress {
    description     = "Allow communication with cluster SG"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.project_cluster_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "project-node-sg" }
}

##########################
# IAM Roles
##########################
resource "aws_iam_role" "project_cluster_role" {
  name = "project-cluster-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "eks.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "project_cluster_role_policy" {
  role       = aws_iam_role.project_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "project_cluster_service_policy" {
  role       = aws_iam_role.project_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_role" "project_node_group_role" {
  name = "project-node-group-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "project_node_group_role_policy" {
  role       = aws_iam_role.project_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "project_node_group_cni_policy" {
  role       = aws_iam_role.project_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "project_node_group_registry_policy" {
  role       = aws_iam_role.project_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

##########################
# EKS Cluster & Node Group
##########################
resource "aws_eks_cluster" "project" {
  name     = "project-cluster"
  role_arn = aws_iam_role.project_cluster_role.arn

  vpc_config {
    subnet_ids         = aws_subnet.project_subnet[*].id
    security_group_ids = [aws_security_group.project_cluster_sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.project_cluster_role_policy,
    aws_iam_role_policy_attachment.project_cluster_service_policy
  ]
}

resource "aws_eks_node_group" "project" {
  cluster_name    = aws_eks_cluster.project.name
  node_group_name = "project-node-group"
  node_role_arn   = aws_iam_role.project_node_group_role.arn
  subnet_ids      = aws_subnet.project_subnet[*].id

  scaling_config {
    desired_size = 5
    max_size     = 5
    min_size     = 3
  }

  instance_types = ["t3.micro"]

  remote_access {
    ec2_ssh_key               = var.ssh_key_name
    source_security_group_ids = [aws_security_group.project_node_sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.project_node_group_role_policy,
    aws_iam_role_policy_attachment.project_node_group_cni_policy,
    aws_iam_role_policy_attachment.project_node_group_registry_policy
  ]
}
