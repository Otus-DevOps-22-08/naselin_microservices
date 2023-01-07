terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "otus-homeworks"
    region     = "ru-central1"
    key        = "terraform/terraform.tfstate"
    access_key = "YourAccessKey"
    secret_key = "YourSecretKey"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
