# Ansible playbooks to setup a basic Kubernetes cluster

This set of playbooks will setup a **single master / control-plane** with as many worker nodes as you like.

## Compatibility
This has been tested on:
- Ubuntu 22.04 Server

## Cluster details

### Suite of base workloads

1. Prometheus monitoring with Slack integration
2. MetalLB load balancing (layer 2)
3. Kubernetes Dashboard (with an admin user)
4. Ingress controller (NGINX, community) - LoadBalancer service type assigned an IP by MetalLB
5. Cert manager to provide TLS certificates
6. Vault - secret storage and injection
7. Longhorn - CSI

### Chosen CRI and CNI

- Container Runtime Interface is containerd.
- Container Network Interface is Calico.

### Installation and versions

This installs the cluster using kubeadm.

The chart versions are specified in the `defaults` folder of their role. The chart values file for the version specified in `defaults` is found in `templates`.

### Kube-proxy

Kube-proxy uses IP Virtual Server (ipvs) as opposed to the default of iptables.

### Configuration and usage

The main versioning / configuration should be specified in the **group_vars** directory. Before use, copy the `master-template.yml` to `master.yml` and add in any secrets.

Suggested playbook order:

```
ansible-playbook -i hosts.yml playbooks/master-setup.yml --ask-become
ansible-playbook -i hosts.yml playbooks/worker-setup.yml --ask-become
ansible-playbook -i hosts.yml playbooks/base-workloads.yml
```

### Joining more workers

The node-token.txt expires after 24hrs of setting up the master node.
To generate a new joining token in the case you want to add more worker nodes, head to the master node and run:

```
kubeadm token create --print-join-token
```

### Vault server TLS checked on apps
To make sure the vault-agent-init container can reach the vault server successfully you need to do the following:
1) Add the root-ca (defined in the cert-manager role) to the namespace of the app in a secret called "vault-server-ca" and with a file called "ca.crt"
2) Add the annotations below to the app (as well as the standard vault annotations)
```
vault.hashicorp.com/ca-cert: /vault/tls/ca.crt
vault.hashicorp.com/tls-secret: vault-server-ca
```
