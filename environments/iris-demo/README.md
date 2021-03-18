# Iris demo cluster

This environment contains the configuration necessary to deploy and configure a
demonstration slurm appliance on the Iris production openstack cloud. Terraform
is used to provision the infrastructure.

This README is supplementary to the main [README.md](../../README.md) so only
differences/additional information is noted here. Paths are relative to this
environment unless otherwise noted.

# Directory structure

## terraform

Contains terraform configuration to deploy infrastructure.

## inventory

Ansible inventory for configuring the infrastructure.

## Installation on deployment host

See [README.md](../../README.md) in the repository root. You should have:

- Installed all the dependencies
- Activated the virtual environment
- Activated the slurm appliance environment

Additionally install `terraform` following its [documentation](https://learn.hashicorp.com/tutorials/terraform/install-cli).

## Creating a Slurm appliance

### Overview of the configuration

The values in `terraform/terraform.tfvars` create a four node cluster:

- 1x login node: Users login to this node to interact with the scheduler.
- 1x control node: Runs the Slurm control daemon, monitoring infrastructure, and
  accounting database
- 2x compute: Worker instances used to run jobs.

The nodes are provisioned in the `demo` project and are attached to a single
network, `demo-vxlan`. A floating ip is attached to the login node to allow
remote access. Access to the logging and monitoring services should be done via
the login node. This is so we do not expose the services on the public internet.
The dynamic port forwarding feature of SSH can used to establish a socks proxy
that proxies all traffic via the login node. This can be used by your local
browser to access the monitoring services. There are various resources online
that detail how to set this up.

See `inventory/hosts` for IP addresses for the currently deployed cluster.

### Deploy instances using Terraform

- Modify variables in `terraform/terraform.tfvars` to define the cluster size
  and cloud environment.
- Configure access to the openstack cloud via clouds.yaml or by using an openrc
  file. Terraform will pick this up from the environment or use the default
  cloud (overridable with OS_CLOUD) if using clouds.yaml. Please see the
  [upstream
  documentation](https://docs.openstack.org/python-openstackclient/latest/configuration/index.html)
  for more details.
- Ensure the appropriate images (Centos 8.2 or 8.3) and SSH keys are available
  in OpenStack.

Then run:

    cd <terraform directory>
    terraform apply

This creates an ansible inventory file in `inventory/hosts`.

### Configuring the infrastructure

Follow all steps in [README.md](../../README.md) in the repository root. In
particular make sure you:

- Generate a set of passwords
- Apply any customisations to the inventory
- Run the site.yml playbook

### User access

The login node is the intended point of entry for users. The terraform
configures a SSH key for the `centos` user. Currently this is the only user that
has access to the system. It is left as an exercise for the reader to add LDAP
integration or configure additional local users.

Note that non-privileged users cannot log into compute nodes unless they have a
running job.

## Destroying the cluster

> **WARNING**: This operation will delete all resources created with terraform. Please make
  sure you have backed up any data you want to keep as the all of the local disks
  in the cluster will be destroyed rendering any data irretrievable.

    cd <terraform directory>
    terraform destroy

This will show you a list of resources that will be destroyed, asking for
confirmation before taking any action.

