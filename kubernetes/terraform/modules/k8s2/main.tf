provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

resource "yandex_kubernetes_cluster" "otus_cluster" {
  name = "test-cluster"

  master {
    zonal {
      zone      = var.zone
      subnet_id = var.k8s_subnet_id
    }
    version   = var.k8s_cluster_version
    public_ip = true
  }
  network_id = var.k8s_network_id

  service_account_id      = var.service_account_id
  node_service_account_id = var.node_service_account_id

  release_channel         = "RAPID"
  network_policy_provider = "CALICO"
}


resource "yandex_kubernetes_node_group" "otus_node_group" {
  name       = "test-group"
  cluster_id = yandex_kubernetes_cluster.otus_cluster.id

  version = var.k8s_cluster_version

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat        = true
      subnet_ids = [var.k8s_subnet_id]
    }

    resources {
      memory = 8
      cores  = 4
      core_fraction = 50
    }

    boot_disk {
      type = "network-ssd"
      size = 64
    }

    scheduling_policy {
      preemptible = false
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }
}
