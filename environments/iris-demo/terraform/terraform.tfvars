# Name of cluster. This is used as a prefix for the node names. Please do not use dashes
# or unserscores.
cluster_name  = "wjsohpc2"

# Public key in openstack keypair list that is used to initially log in to the cluster
key_pair = "service"

# Internal network
network = "demo-vxlan"

# Needs to be specified by uuid as otherwise, you hit:
# Your query returned more than one result. Please try a more specific search criteria
external_network = "a929e8db-1bf4-4a5f-a80c-fabd39d06a26"

# Login node specification
login_image = "CentOS8-1911"
login_flavor = "general.v1.tiny"

# Control node specification
control_image = "CentOS8-1911"
control_flavor = "general.v1.tiny"

# Compute node specification
compute_count = 2
compute_image = "CentOS8-1911"
compute_flavor = "general.v1.tiny"
