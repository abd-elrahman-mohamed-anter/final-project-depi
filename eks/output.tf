##########################
# Outputs
##########################
output "cluster_id" {
  value = aws_eks_cluster.project.id
}

output "node_group_id" {
  value = aws_eks_node_group.project.id
}

output "vpc_id" {
  value = aws_vpc.project_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.project_subnet[*].id
}

output "cluster_endpoint" {
  value = aws_eks_cluster.project.endpoint
}

output "cluster_certificate" {
  value = aws_eks_cluster.project.certificate_authority[0].data
}
