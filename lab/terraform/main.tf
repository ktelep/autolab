terraform {
  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = "1.9.4"
    }
  }
}

data "nutanix_cluster" "cluster" {
  name = var.cluster_name
}
data "nutanix_subnet" "subnet" {
  subnet_name = var.subnet_name
}

provider "nutanix" {
  username     = var.user
  password     = var.password
  endpoint     = var.endpoint
  insecure     = true
  wait_timeout = 60
}

# If we want to grab a remote image, we could use this and create it
#resource "nutanix_image" "image" {
#  name        = "Ubuntu_22.04"
#  description = "Ubuntu 22.04 Image"
#  source_uri  = "http://10.136.239.13/workshop_staging/tradeshows/os_builds/linux/ubuntu/tradeshow-ubuntu22.04.qcow2"
#}

resource "nutanix_virtual_machine" "vm" {
  name                 = "User##-TERRAFORM"
  cluster_uuid         = data.nutanix_cluster.cluster.id
  num_vcpus_per_socket = "2"
  num_sockets          = "1"
  memory_size_mib      = 1024
  use_hot_add	       = true
  guest_customization_cloud_init_user_data = "I2Nsb3VkLWNvbmZpZwpmcWRuOiB1c2VyMjAKc3NoX3B3YXV0aDogdHJ1ZQp1c2VyczoKICAtIG5hbWU6IG51dGFuaXgKICAgIHNzaF9wd2F1dGg6IFRydWUKICAgIHN1ZG86IFsnQUxMPShBTEwpIE5PUEFTU1dEOkFMTCddCmNocGFzc3dkOgpjaHBhc3N3ZDoKICBsaXN0OiB8CiAgICByb290Om51dGFuaXgvNHUKICAgIG51dGFuaXg6bnV0YW5peC80dQogIGV4cGlyZTogRmFsc2UK"
  disk_list {
    data_source_reference = {
      kind = "image"
      uuid = "33f9ccd1-e578-4567-9971-43f90187b9f9"
    }
  }

  disk_list {
    disk_size_bytes = 20 * 1024 * 1024 * 1024
    device_properties {
      device_type = "DISK"
      disk_address = {
        "adapter_type" = "SCSI"
        "device_index" = "1"
      }
    }
  }

  nic_list {
    subnet_uuid = data.nutanix_subnet.subnet.id
  }
}
