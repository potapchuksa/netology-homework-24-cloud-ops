resource "yandex_vpc_network" "my-network" {
  name = "my-network"
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  network_id     = yandex_vpc_network.my-network.id
  zone           = var.default_zone
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  network_id     = yandex_vpc_network.my-network.id
  zone           = var.default_zone
  v4_cidr_blocks = ["192.168.20.0/24"]
  
  route_table_id = yandex_vpc_route_table.private-rt.id
}

resource "yandex_vpc_route_table" "private-rt" {
  name       = "private-rt"
  network_id = yandex_vpc_network.my-network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"
  }
}
