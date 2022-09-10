# Ansible playbooks to setup a basic Kubernetes cluster

This set of playbooks will setup a **single master / control-plane** with as many worker nodes as you like.

## Cluster details

### Suite of base workloads

1. Prometheus monitoring with Slack integration
2. MetalLB load balancing (layer 2)
3. Kubernetes Dashboard (with an admin user)
4. Ingress controller (NGINX, community) - LoadBalancer service type assigned an IP by MetalLB
5. Cert manager to provide TLS certificates
6. Vault - secret storage and injection

### Chosen CRI and CNI

- Container Runtime Interface is containerd.
- Container Network Interface is Calico.

### Installation and versions

This installs the cluster using kubeadm.
The main versioning / configuration should be specified in the **group_vars** directory. Before use, copy the `master-template.yml` to `master.yml` and add in any secrets.

The chart versions are specified in the `defaults` folder of their role. The chart values file for the version specified in `defaults` is found in `templates`.

### CIDRs

The below are set in the `defaults` of the kubeadm-init role:

- Service CIDR: 10.96.0.0/16
- Pod CIDR: 10.244.0.0/16

### Kube-proxy

Kube-proxy uses IP Virtual Server (ipvs) as opposed to the default of iptables.

### Joining more workers

The node-token.txt expires after 24hrs of setting up the master node.
To generate a new joining token in the case you want to add more worker nodes, head to the master node and run:

```
kubeadm token create --print-join-token
```
