[all]
${connection_strings_master}
${connection_strings_worker}

[kube_control_plane]
${list_master}

[etcd]
${list_master}

[kube_node]
${list_worker}

[k8s_cluster:children]
<<<<<<< HEAD
kube_control_plane
kube_node
=======
kube-master
kube-node
>>>>>>> 2cb8c8544 (Fix logical error when checking for boostrap-os (#10867) (#10953))

[k8s_cluster:vars]
network_id=${network_id}
