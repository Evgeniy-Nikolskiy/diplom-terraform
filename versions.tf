terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
} 

provider "yandex" {
  #Ключи сохранены в переменых среды:
  #YC_TOKEN, YC_CLOUD_ID, YC_FOLDER_ID
  zone = "ru-central1-a"
}