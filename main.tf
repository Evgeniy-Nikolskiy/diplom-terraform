locals {
  zone = "ru-central1-a"
  nat_image_id = "fd80mrhj8fl2oe87o4e1"
  public_subnet = ["192.168.10.0/24"]
  private_subnet = ["192.168.20.0/24"]
  nat_gw = "192.168.10.254"
}

provider "yandex" {
  token = "AQAAAAAS9j4ZAATuwaB6EWjQVE5PuHLDBOmXiaI"  
  cloud_id = "b1gm53rrhubfia3qpp2g"
  folder_id = "b1gg49lefs6j79btf13t"
  zone = "ru-central1-a"
}

# AlmaLinux 8 image
data "yandex_compute_image" "alma8" {
  family = "almalinux-8"
}

// Создание статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = "ajemtk9h8g4aqcqa9ncv"
  description        = "static access key for object storage"
}

// Создание бакета с использованием ключа
resource "yandex_storage_bucket" "test" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "terraform-bucket-diplom"
}

resource "yandex_vpc_network" "vpc-diplom" {
  name = "vpc-diplom"
}

# Создать route table. Добавить статический маршрут, направляющий весь исходящий трафик private сети в NAT-инстанс
resource "yandex_vpc_route_table" "via-nat" {
  network_id = yandex_vpc_network.vpc-diplom.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address = local.nat_gw
  }
}

# Создать в vpc subnet с названием public, сетью 192.168.10.0/24.
resource "yandex_vpc_subnet" "public" {
  v4_cidr_blocks = local.public_subnet
  zone = local.zone
  network_id = yandex_vpc_network.vpc-diplom.id
}

# Создать в vpc subnet с названием private, сетью 192.168.20.0/24.
resource "yandex_vpc_subnet" "private" {
  v4_cidr_blocks = local.private_subnet
  zone = local.zone
  network_id = yandex_vpc_network.vpc-diplom.id
  route_table_id = yandex_vpc_route_table.via-nat.id
}

# Создать в этой подсети NAT-инстанс,
resource "yandex_compute_instance" "nat-instance" {
  name = "nat-instance"
  hostname = "nat-instance"

  resources {
    cores = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      # В качестве image_id использовать fd80mrhj8fl2oe87o4e1
      image_id = local.nat_image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    # присвоив ему адрес 192.168.10.254
    ip_address = local.nat_gw
    nat = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "evgen:${file("~/.ssh/id_rsa.pub")}"
  }
}

# Create test VMs

resource "yandex_compute_instance" "test-public-vm" {
  name = "test-public-vm"
  hostname = "test-public-vm"

  resources {
    cores = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.alma8.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "evgen:${file("~/.ssh/id_rsa.pub")}"
  }
}


resource "yandex_compute_instance" "test-private-vm" {
  name = "test-private-vm"
  hostname = "test-private-vm"

  resources {
    cores = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.alma8.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "evgen:${file("~/.ssh/id_rsa.pub")}"
  }
}