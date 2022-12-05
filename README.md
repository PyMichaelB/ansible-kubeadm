# Ansible playbooks to setup a Kubernetes cluster

You should set up an odd number of control planes.
Minimums should be three control planes and three workers.

## Compatibility
This has been tested on:
- Ubuntu 22.04 Server

# Cluster details

## Suite of base workloads

1. Prometheus monitoring with Slack integration
2. MetalLB load balancing
3. Kubernetes Dashboard
4. Ingress controller
5. Cert manager to provide TLS certificates
6. Vault - secret storage and injection
7. Harbor image registry

All of these workloads are optional - remove roles from the playbook `base-workloads.yml` to suit or alternatively if you want a base cluster with none of the above workloads just run the master and worker playbooks.

## Implementation specifics

- Container Runtime Interface is containerd.
- Container Network Interface is Calico.
- Container Storage Interface (default) is Longhorn.
- Kube-proxy uses IPVS as opposed to the default of iptables.

## Installation and versions

* The main configuration should be specified in the **group_vars** directory. Before use, copy the `all-template.yml` to `all.yml` and add in all missing details (and change the default hostname to one you have control over).

* Additionally, copy the `hosts-template.yml` to `hosts.yml` and fill in the details of your hardware.

### Playbooks
* The cluster will be initialised on the first control plane listed in the `hosts.yml` file.
* The rest of the control planes will be joined as part of `master-setup.yml`.
* All the workers will be joined as part of `worker-setup.yml`.
* This installs the cluster using kubeadm. Once you have run the master setup job, copy the admin config from `/home/{{ ansible_user }}/.kube/config` to your workstation so you do not need to SSH to the node to use `kubectl`.

### Chart versions
The chart versions are specified in the `defaults` folder of their role. The chart values file for the version specified in `defaults` is found in `templates`.


### Joining more control planes or workers

The node-token.txt expires after 24hrs of setting up the first control plane node.
To generate a new joining token in the case you want to add more control planes or worker nodes, head to a control plane node and run:

```
kubeadm token create --print-join-token
```

## Workload specifics
### cert-manager
Upon installation, cert-manager will create the root-ca for the cluster and associated processes. It will be given the name `root-ca-secret` and stored in the cert-manager namespace.

Once this has been generated, please extract the `ca.crt` from the secret and install this as a trusted root CA on all machines that need to interact with any cluster service using TLS e.g. your workstation, and all cluster nodes.

Additionally, any images that interact with e.g. cluster ingress using HTTPS, must have this root-ca baked into them.

### Vault server
When using the vault agent injector to get secrets into applications we need to make sure the vault-agent-init container can talk to the vault server with TLS.
To enable this, you need to do the following:
1) Add the `root-ca` to the namespace of the app in a secret called `root-ca` and a file called `ca.crt`
2) Add the annotations below to the app (as well as the standard vault annotations)
```
vault.hashicorp.com/ca-cert: /vault/tls/ca.crt
vault.hashicorp.com/tls-secret: root-ca
```
### Ingress
The following services are exposed using the `ingress-nginx` controller and have TLS terminated:
- Prometheus
- Grafana
- Kubernetes Dashboard
- Any apps you deploy with ingress (assuming you give them an `nginx` ingressClassName)

Therefore, for the two monitoring applications above, you **must** make sure you change the default admin password.

### LoadBalancer service types
The following are `LoadBalancer` type services and terminate TLS at the application itself:
- Vault
- Harbor
- (the ingress controller itself)

### Harbor
After installing Harbor you need to setup the image pull secrets in Kubernetes to be able to pull images from it.
To do this, login with the default admin credentials (found in the values file) and then change the admin password.
Then, create a new robot user and save the secret.

Then, to create the image pull secret see:
https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/