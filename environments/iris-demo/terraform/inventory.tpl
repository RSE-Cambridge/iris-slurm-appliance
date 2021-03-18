[all:vars]
ansible_user=centos
ssh_proxy=${proxy}
openhpc_cluster_name=${cluster_name}

[${cluster_name}_login]
${login.name} ansible_host=${login.network[0].fixed_ip_v4} server_networks='${jsonencode({for net in login.network: net.name => [ net.fixed_ip_v4 ] })}'

[${cluster_name}_control]
${control.name} ansible_host=${control.network[0].fixed_ip_v4} server_networks='${jsonencode({for net in control.network: net.name => [ net.fixed_ip_v4 ] })}'

[${cluster_name}_compute]
%{ for compute in computes ~}
${compute.name} ansible_host=${compute.network[0].fixed_ip_v4} server_networks='${jsonencode({for net in compute.network: net.name => [ net.fixed_ip_v4 ] })}'
%{ endfor ~}

[requires_jumphost:children]
${cluster_name}_control
${cluster_name}_login
${cluster_name}_compute

[cluster_login:children]
${cluster_name}_login

# NOTE: This is hardcoded in the tests role
[cluster_compute:children]
${cluster_name}_compute

[cluster_control:children]
${cluster_name}_control

[login:children]
cluster_login

[compute:children]
cluster_compute

[control:children]
cluster_control

[cluster:children]
login
control
compute

[requires_jumphost:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh centos@${proxy} -W %h:%p"'
