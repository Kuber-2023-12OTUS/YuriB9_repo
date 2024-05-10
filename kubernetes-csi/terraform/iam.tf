
#SECTION Service Accounts

resource "yandex_iam_service_account" "sa-s3" {
  name      = "sa-s3-otus"
  folder_id = var.folder_id
}


#SECTION Service Account folder bindings

resource "yandex_resourcemanager_folder_iam_binding" "storage-editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa-s3.id}"
  ]
}


#SECTION Service Account static access keys

resource "yandex_iam_service_account_static_access_key" "sa-s3-static-key" {
  service_account_id = yandex_iam_service_account.sa-s3.id
}
