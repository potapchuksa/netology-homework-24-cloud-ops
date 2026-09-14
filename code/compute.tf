locals {
  # Специализированный образ Yandex Cloud с уже настроенным NAT и ip_forward
  image_id = "fd80mrhj8fl2oe87o4e1" 
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

# 1. NAT-инстанс в публичной подсети
resource "yandex_compute_instance" "nat" {
  name        = "nat-instance"
  platform_id = "standard-v3"
  zone        = var.default_zone

  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = local.image_id
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    ip_address = "192.168.10.254"
    nat        = true
  }
}

# 2. Публичная виртуальная машина (для проверки)
resource "yandex_compute_instance" "public-vm" {
  name        = "public-vm"
  hostname    = "public-vm"
  platform_id = "standard-v3"
  zone        = var.default_zone

  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_key}"
  }
}

# 3. Приватная виртуальная машина
resource "yandex_compute_instance" "private-vm" {
  name        = "private-vm"
  hostname    = "private-vm"
  platform_id = "standard-v3"
  zone        = var.default_zone

  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    nat       = false # Без публичного IP
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_key}"
  }
}

output "public_vm_nat_ip" {
  value = yandex_compute_instance.public-vm.network_interface[0].nat_ip_address
}

output "private_vm_internal_ip" {
  value = yandex_compute_instance.private-vm.network_interface[0].ip_address
}
