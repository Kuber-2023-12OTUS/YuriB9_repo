module "kube" {
  cluster_version = "1.28"
  source          = "github.com/terraform-yc-modules/terraform-yc-kubernetes.git"
  network_id      = yandex_vpc_network.vpc-01.id

  master_locations = [
    {
      zone      = "ru-central1-a",
      subnet_id = yandex_vpc_subnet.snet-01.id
    }
  ]

  master_maintenance_windows = [
    {
      day        = "monday"
      start_time = "23:00"
      duration   = "3h"
    }
  ]

  node_groups = {

    "ng-01" = {
      node_memory = 2
      node_cores  = 2
      disk_size   = 30
      description = "Kubernetes infra group 01"
      fixed_scale = {
        size = 1
      }
      node_labels = {
        role        = "infra-01"
        environment = "infra"
      }
      node_taints = [
        "node-role=infra:NoSchedule"
      ]

    },

    "ng-02" = {
      node_memory = 2
      node_cores  = 2
      disk_size   = 30
      description = "Kubernetes worker group 01"
      fixed_scale = {
        size = 1
      }
      node_labels = {
        role        = "worker-01"
        environment = "dev"
      }

      max_expansion   = 1
      max_unavailable = 1
    }
  }
}
