
output "master_ip" {
  value = module.kubernetes.master_ip
}

output "worker_ip" {
  value = module.kubernetes.worker_ip
}

<<<<<<< HEAD
output "bastion_ip" {
  value = module.kubernetes.bastion_ip
}

=======
>>>>>>> 2cb8c8544 (Fix logical error when checking for boostrap-os (#10867) (#10953))
output "loadbalancer_domain" {
  value = module.kubernetes.loadbalancer_domain
}
