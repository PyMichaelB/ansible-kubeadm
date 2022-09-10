# Ansible playbooks to setup a basic Kubernetes cluster

This set of playbooks will setup a single master / control-plane with as many workers as you like.

Suite of base workloads:
1) Prometheus monitoring with Slack integration
2) MetalLB load balancing (layer 2)
3) Kubernetes Dashboard (with an admin user)
4) Ingress controller (NGINX, community) - LoadBalancer service type assigned an IP by MetalLB
5) Cert manager to provide TLS certificates
6) Vault - secret storage and injection
