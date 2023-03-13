# Custom k8s cluster
#output "external_ip_address" {
#  value = module.k8s1.external_ip_address
#}

# YC managed service for k8s
output "cluster_external_v4_endpoint" {
  value = module.k8s2.cluster_external_v4_endpoint
}
