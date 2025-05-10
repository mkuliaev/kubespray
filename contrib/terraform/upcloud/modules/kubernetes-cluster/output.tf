<<<<<<< HEAD
output "master_ip" {
  value = local.master_ip
}

output "worker_ip" {
  value = local.worker_ip
}

output "bastion_ip" {
  value = local.bastion_ip
=======

output "master_ip" {
  value = {
    for instance in upcloud_server.master :
    instance.hostname => {
      "public_ip" : instance.network_interface[0].ip_address
      "private_ip" : instance.network_interface[1].ip_address
    }
  }
}

output "worker_ip" {
  value = {
    for instance in upcloud_server.worker :
    instance.hostname => {
      "public_ip" : instance.network_interface[0].ip_address
      "private_ip" : instance.network_interface[1].ip_address
    }
  }
>>>>>>> 2cb8c8544 (Fix logical error when checking for boostrap-os (#10867) (#10953))
}

output "loadbalancer_domain" {
  value = var.loadbalancer_enabled ? upcloud_loadbalancer.lb[0].dns_name : null
}
