variable "cloud_id" {
  description = "Cloud"
}
variable "folder_id" {
  description = "Folder"
}
variable "zone" {
  description = "Zone"
  default     = "ru-central1-a"
}
variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}
variable "private_key_path" {
  description = "Path to the private key used for ssh access"
}
variable "subnet_id" {
  description = "Subnet"
}
variable "service_account_key_file" {
  description = "key.json"
}
variable "image_id" {
  description = "Disk image"
}
variable "nodes_count" {
  description = "Nodes count"
  default     = 2
}

# K8s service setup
variable "k8s_subnet_id" {
  description = "Subnet"
}
variable "k8s_cluster_version" {
  description = "K8s cluster version"
  default     = 1.23
}
variable "k8s_network_id" {
  description = "K8s network"
}
variable "service_account_id" {
  description = "K8s cluster service account"
}
variable "node_service_account_id" {
  description = "K8s nodes service account"
}
variable "nodes_in_group" {
  description = "Nodes in group count"
}
