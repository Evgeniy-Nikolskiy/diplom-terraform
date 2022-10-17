terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}
provider "yandex" {
  token = "AQAAAAAS9j4ZAATuwaB6EWjQVE5PuHLDBOmXiaI"  
  cloud_id = "b1gm53rrhubfia3qpp2g"
  folder_id = "b1gg49lefs6j79btf13t"
  zone = "ru-central1-a"
}