               # Centos 7 image

data "yandex_compute_image" "centos7" {
  family = "centos-7"
}

               # Создание статического ключа доступа

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = "ajemtk9h8g4aqcqa9ncv"
  description        = "static access key for object storage"
}

               # Создание бакета с использованием ключа

resource "yandex_storage_bucket" "test" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "terraform-bucket-diplom"
}

        # Создать в vpc сеть с названием master_sub

resource "yandex_vpc_network" "vpc_diplom" {
  name = "vpc_diplom"
}

              # Создать в vpc subnet с названием master_sub, сетью 10.129.0.0/24.

resource "yandex_vpc_subnet" "master_sub" {
  name           = "master_sub"
  v4_cidr_blocks = ["10.129.0.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc_diplom.id
}

              # Создать в vpc subnet с названием node_sub, сетью 10.130.0.0/24.


resource "yandex_vpc_subnet" "node_sub" {
  name           = "node_sub"
  v4_cidr_blocks = ["10.130.0.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.vpc_diplom.id
}



              # Create VMs


resource "yandex_compute_instance" "master_vm" {
  name     = "master"
  hostname = "master"

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.centos7.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.master_sub.id
    nat       = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata   = {
    user-data = "${file("/home/evgen/repo/diplom-terraform/metadata.yml")}"
    serial-port-enable = 1
  }
}

resource "yandex_compute_instance" "node1_vm" {
  name     = "node1"
  hostname = "node1"
  zone     = "ru-central1-b"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.centos7.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.node_sub.id
    nat       = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata   = {
    user-data = "${file("/home/evgen/repo/diplom-terraform/metadata.yml")}"
    serial-port-enable = 1
  }
}

resource "yandex_compute_instance" "node2_vm" {
  name     = "node2"
  hostname = "node2"
  zone     = "ru-central1-b"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.centos7.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.node_sub.id
    nat       = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata   = {
    user-data = "${file("/home/evgen/repo/diplom-terraform/metadata.yml")}"
    serial-port-enable = 1
  }
}
