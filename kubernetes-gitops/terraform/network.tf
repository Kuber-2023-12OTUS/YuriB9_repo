
# SECTION VPC
resource "yandex_vpc_network" "vpc-01" {
  name = "vpc-01"
}

# SECTION Subnets
resource "yandex_vpc_subnet" "snet-01" {
  name           = "snet-01"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc-01.id
  v4_cidr_blocks = ["10.5.0.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_gateway" "nat_gateway" {
  folder_id = var.folder_id
  name      = "k8s-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  folder_id  = var.folder_id
  name       = "test-route-table"
  network_id = yandex_vpc_network.vpc-01.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}
