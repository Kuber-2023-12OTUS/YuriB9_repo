provider "yandex" {
  service_account_key_file = "sa-terraform-authorized-key.json"
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = "ru-central1-a"
}
