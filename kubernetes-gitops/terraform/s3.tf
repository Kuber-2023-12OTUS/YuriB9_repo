resource "yandex_storage_bucket" "sb-otus-01" {
  bucket     = "sb-otus-01"
  folder_id  = var.folder_id
  access_key = yandex_iam_service_account_static_access_key.sa-s3-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-s3-static-key.secret_key
}