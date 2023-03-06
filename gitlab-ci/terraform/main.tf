provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

resource "yandex_compute_instance" "gitlab" {
  name     = "gitlab-node${count.index}"
  hostname = "gitlab-node${count.index}.internal"

  count = var.nodes_count

  zone = var.zone

  resources {
    cores         = 2
    core_fraction = 100
    memory        = 8
  }


  boot_disk {
    initialize_params {
      image_id = var.image_id
      size = 50
      type = "network-ssd"
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
