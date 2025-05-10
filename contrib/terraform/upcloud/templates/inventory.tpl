<<<<<<< HEAD
[all]
%{ for name, ips in master_ip ~}
${name} ansible_user=${username} ansible_host=${lookup(ips, "public", ips.private)} ip=${ips.private}
%{ endfor ~}
%{ for name, ips in worker_ip ~}
${name} ansible_user=${username} ansible_host=${lookup(ips, "public", ips.private)} ip=${ips.private}
%{ endfor ~}

[kube_control_plane]
%{ for name, ips in master_ip ~}
${name}
%{ endfor ~}

[etcd]
%{ for name, ips in master_ip ~}
${name}
%{ endfor ~}

[kube_node]
%{ for name, ips in worker_ip ~}
${name}
%{ endfor ~}
=======

[all]
${connection_strings_master}
${connection_strings_worker}

[kube_control_plane]
${list_master}

[etcd]
${list_master}

[kube_node]
${list_worker}
>>>>>>> 2cb8c8544 (Fix logical error when checking for boostrap-os (#10867) (#10953))

[k8s_cluster:children]
kube_control_plane
kube_node
<<<<<<< HEAD

%{ if length(bastion_ip) > 0 ~}
[bastion]
%{ for name, ips in bastion_ip ~}
bastion ansible_user=${username} ansible_host=${ips.public}
%{ endfor ~}
%{ endif ~}
=======
>>>>>>> 2cb8c8544 (Fix logical error when checking for boostrap-os (#10867) (#10953))
