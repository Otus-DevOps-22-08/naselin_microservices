provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

resource "yandex_compute_instance" "k8s" {
  name     = "k8s-node${count.index}"
  hostname = "k8s-node${count.index}.internal"

  count = var.nodes_count

  zone = var.zone

  resources {
    cores         = 4
    core_fraction = 20
    memory        = 4
  }


  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 40
      type     = "network-ssd"
    }
  }

  network_interface {
    # default-ru-central1-a
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
}
