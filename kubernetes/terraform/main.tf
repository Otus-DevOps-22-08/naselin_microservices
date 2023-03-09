# Custom k8s cluster
#module "k8s1" {
#  source                   = "./modules/k8s1"
#  public_key_path          = var.public_key_path
#  subnet_id                = var.subnet_id
#  service_account_key_file = var.service_account_key_file
#  cloud_id                 = var.cloud_id
#  folder_id                = var.folder_id
#  image_id                 = var.image_id
#  nodes_count              = var.nodes_count
#}

# YC managed service for k8s
module "k8s2" {
  source                   = "./modules/k8s2"
  public_key_path          = var.public_key_path
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  k8s_cluster_version      = var.k8s_cluster_version
  k8s_network_id           = var.k8s_network_id
  k8s_subnet_id            = var.k8s_subnet_id
  service_account_id       = var.service_account_id
  node_service_account_id  = var.node_service_account_id
  nodes_in_group           = var.nodes_in_group
}
