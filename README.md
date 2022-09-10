# Ansible playbooks to setup a basic Kubernetes cluster

This set of playbooks will setup a **single master / control-plane** with as many worker nodes as you like.

Suite of base workloads:
1) Prometheus monitoring with Slack integration
2) MetalLB load balancing (layer 2)
3) Kubernetes Dashboard (with an admin user)
4) Ingress controller (NGINX, community) - LoadBalancer service type assigned an IP by MetalLB
5) Cert manager to provide TLS certificates
6) Vault - secret storage and injection

This installs the cluster using kubeadm.
The Container Runtime Interface is containerd.
The Container Network Interface is Calico.

Service CIDR: 10.96.0.0/16
Pod CIDR: 10.244.0.0/16

Kube-proxy uses IP Virtual Server (ipvs) as opposed to the default of iptables.

To generate a new joining token (the worker playbook should be run within 24hrs of the master being setup), head to the master node and run:
```
kubeadm token create --print-join-token
```
