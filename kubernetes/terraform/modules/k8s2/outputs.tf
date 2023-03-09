output "cluster_external_v4_endpoint" {
  value = yandex_kubernetes_cluster.otus_cluster.master.0.external_v4_endpoint
}
