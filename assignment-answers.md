# Assignment Answers

## Custom NGINX Website

### What is `healthz`?

`healthz` is a small health-check endpoint or file. It gives a simple response such as `ok` so Docker, Kubernetes, or a person can quickly verify that the site is reachable and healthy.

### Where does NGINX come in?

NGINX is the web server that serves the files in the site. The HTML and CSS are the website content, and NGINX is the software that delivers that content over HTTP.

## Docker

### What is Docker?

Docker packages an application and its runtime into an image, then runs that image as a container.

### Why use an unprivileged image?

It is safer. The container does not run as root, which reduces the damage a bug or misconfiguration can cause.

## Docker Compose

### What does `docker compose up -d` do?

It starts the services defined in `compose.yaml` and runs them in detached mode, which means they stay running in the background while your terminal is free again.

### Why use `compose.yaml`?

It makes the app reproducible. Instead of remembering a long `docker run` command, the container settings live in code and can be started with one local command.

## Terraform

### What is Terraform?

Terraform is infrastructure as code. You describe cloud resources in `.tf` files, then Terraform creates or changes the real infrastructure to match that description.

### What is the difference between Docker and Terraform?

Docker packages and runs an application container. Terraform creates and manages infrastructure such as networks, storage, databases, VMs, and Kubernetes clusters.

## Local Kubernetes

### What is the difference between Docker and Kubernetes?

Docker builds and runs containers. Kubernetes manages containers at a higher level by handling deployment, scaling, networking, health checks, and service discovery.

### Why verify the current context?

Because `kubectl` only acts on the active cluster context. If the context is wrong, you can accidentally change resources in the wrong cluster.

### What is `kind`?

`kind` means Kubernetes in Docker. It creates a local Kubernetes cluster using Docker containers so you can practice safely on your own machine.

## Running the Image in Kubernetes

### Why load the image into `kind`?

Your local Docker image is not automatically visible inside the `kind` cluster. `kind load docker-image ...` copies that image into the cluster so Kubernetes can run it.

### What is a Deployment?

A Deployment tells Kubernetes how to run and update a set of pods, including the image, replica count, probes, and resource settings.

### What is a Service?

A Service gives pods a stable internal network identity. A `ClusterIP` Service exposes the app inside the cluster and can be reached locally with `kubectl port-forward`.

### What does `kubectl port-forward` do?

It temporarily maps a local port on your machine to a pod or Service in the cluster so you can test it in a browser or with `curl`.

## Debugging Kubernetes Failures

### What is `ImagePullBackOff`?

It means Kubernetes could not pull the container image, usually because the image name or tag is wrong or the image is unavailable.

### Why can a Service have no endpoints?

If the Service selector does not match the pod labels, the Service exists but is not connected to any pods.

### What is the difference between `Running` and `Ready`?

`Running` means the container process has started. `Ready` means Kubernetes believes the pod is healthy enough to receive traffic.

## Monitoring

### What is Prometheus?

Prometheus is the metrics collector and time-series database. In this project, it scrapes Kubernetes and workload metrics and stores them so they can be queried over time.

### What is Grafana?

Grafana is the user interface on top of Prometheus. It connects to Prometheus as a data source and turns metrics into dashboards, panels, and alert rules.

### What was deployed?

- Grafana was deployed in namespace `grafana-kristian`.
- Prometheus was deployed in namespace `monitoring` using `kube-prometheus-stack`.
- The bundled Grafana in `kube-prometheus-stack` was disabled because a separate Grafana release was already used.

### How does Grafana connect to Prometheus?

Grafana uses a Prometheus data source pointing to:

`http://monitoring-kube-prometheus-prometheus.monitoring.svc:9090`

That is the internal Kubernetes Service for Prometheus inside the cluster.

### What does the dashboard show?

The dashboard covers:

- pod CPU usage
- pod memory usage
- pod restart count
- deployment ready replicas
- deployment unavailable replicas
- node health

### What alert was created?

A Grafana-managed alert was created for unavailable replicas of the `kristian-web` Deployment in namespace `kristian-lab`.

The alert condition is based on:

`kube_deployment_status_replicas_unavailable{namespace="kristian-lab", deployment="kristian-web"} > 0`

The alert was verified by triggering a controlled failure and confirming that it fired inside Grafana.

### What limitations were found?

- NGINX ingress metrics were not available because the ingress controller had metrics disabled in this cluster.
- Email notifications were not configured because SMTP was not configured in Grafana.

## Azure Portal Infrastructure Investigation

### How do I find the correct Azure subscription?

Open Azure Portal and search for `Subscriptions`. Select `StagingCSP`.

This subscription is the top-level Azure boundary for the staging environment. It contains resource groups such as my Terraform lab resource group and the shared AKS resource group.

Confirmed subscription:

- Name: `StagingCSP`
- Subscription ID: `0c4be6f5-0bcc-42f0-af63-8c23938dcd59`

### How do I find my Terraform resource group?

In Azure Portal, search for `Resource groups`, then open `rg-kristian-devops-lab`.

The resource group is a logical container for related Azure resources. My lab resource group contains the Azure resources created by Terraform.

Confirmed resource group:

- Name: `rg-kristian-devops-lab`
- Location: `westeurope`

To find the resource ID and tags:

- Open the resource group.
- Use `Overview` for the basic details.
- Use `Properties` for the resource ID.
- Use `Tags` for metadata labels.
- If the information is hard to find in the normal portal view, open `JSON View` and look for fields such as `id`, `location`, `tags`, and `properties`.

Tags are metadata labels attached to Azure resources. They are useful for ownership, cost tracking, filtering, and showing how the resource is managed. In this project, Terraform applies common tags such as owner, environment, project, and `managed_by = terraform`.

### Which Azure resources did Terraform create?

Terraform created resources in `rg-kristian-devops-lab`.

Confirmed from Azure Portal / Azure CLI:

- `vnet-kristian-devops-lab`
- `stkriscusesv`
- `acrkristgj4zya`

These match the Terraform configuration in the repository:

- `azurerm_resource_group.lab` creates `rg-kristian-devops-lab`.
- `azurerm_virtual_network.lab` creates `vnet-kristian-devops-lab`.
- `azurerm_subnet.application` creates `snet-application`.
- `azurerm_storage_account.lab` creates the storage account named `stkris...`, in this environment `stkriscusesv`.
- `azurerm_storage_container.application` creates the private blob container `application`.
- `azurerm_container_registry.lab` creates the ACR named `acrkrist...`, in this environment `acrkristgj4zya`.

### What does each Terraform resource do?

`rg-kristian-devops-lab` is the resource group that contains my lab infrastructure.

`vnet-kristian-devops-lab` is an Azure Virtual Network. It defines a private network range for Azure resources. In Terraform, its address space is `10.50.0.0/16`.

`snet-application` is a subnet inside the virtual network. A subnet divides the VNet into a smaller address range. In Terraform, its address range is `10.50.1.0/24`.

`stkriscusesv` is an Azure Storage Account. It can contain storage services such as blob containers. In this project, Terraform configures it as:

- Tier: `Standard`
- Replication: `LRS`
- Minimum TLS version: `TLS1_2`
- Public network access: disabled
- Shared access key: disabled
- OAuth authentication: enabled by default

`application` is a private blob container inside the storage account.

`acrkristgj4zya` is an Azure Container Registry. It stores Docker images used by the project. In this project, it uses:

- SKU / pricing plan: `Basic`
- Admin user: disabled
- Login server: `acrkristgj4zya.azurecr.io`

### How do I inspect the shared AKS cluster?

In Azure Portal, search for `Kubernetes services`, then open `kubernetes` in resource group `kubernetes-stg`.

The AKS cluster is where Kubernetes workloads run. It is separate from my Terraform lab resource group because it is an existing shared staging cluster.

Confirmed AKS details:

- Name: `kubernetes`
- Resource group: `kubernetes-stg`
- Resource ID: `/subscriptions/0c4be6f5-0bcc-42f0-af63-8c23938dcd59/resourcegroups/kubernetes-stg/providers/Microsoft.ContainerService/managedClusters/kubernetes`
- Location: `westeurope`
- Tags: `env = Staging`
- Provisioning state: `Succeeded`
- Power state: `Running`
- Kubernetes version: `1.35.5`
- Current Kubernetes version: `1.35.5`
- FQDN: `kubernetes-stg-a9rens1h.hcp.westeurope.azmk8s.io`
- Node resource group: `MC_kubernetes-stg_kubernetes_westeurope`
- RBAC: enabled
- Azure RBAC: enabled
- Network plugin: `azure`
- Service CIDR: `10.0.0.0/16`
- DNS service IP: `10.0.0.10`
- Load balancer SKU: `standard`

If these fields are not visible in the normal portal view, use `JSON View` and look under `id`, `location`, `tags`, and `properties`.

### What node pool does AKS use?

The cluster has a node pool named `system`.

Confirmed node pool details:

- Name: `system`
- Mode: `System`
- VM size: `Standard_D4s_v5`
- Current node count: `4`
- Autoscaling: enabled
- Minimum count: `1`
- Maximum count: `5`
- Type: `VirtualMachineScaleSets`
- OS type: `Linux`
- OS SKU: `Ubuntu`
- Node public IP: disabled
- Kubernetes version: `1.35.5`

An AKS node pool is a group of Azure VMs that Kubernetes can schedule pods onto. The Grafana pod runs on one of these AKS worker nodes.

### How do I find Grafana in Kubernetes?

Grafana runs inside Kubernetes in the namespace `grafana-kristian`.

Useful read-only command:

```bash
kubectl get all,ingress,secret -n grafana-kristian
```

Confirmed Grafana resources:

- Pod: `grafana-7674d844ff-j9x64`
- Pod status: `Running`
- Pod readiness: `1/1`
- Pod IP: `10.224.0.61`
- Node: `aks-system-25744230-vmss00000b`
- Deployment: `deployment/grafana`
- Service: `service/grafana`
- Service type: `ClusterIP`
- Service cluster IP: `10.0.191.142`
- Service port: `80/TCP`
- Ingress: `ingress/grafana`
- Ingress class: `nginx`
- Ingress host: `grafana-kristian.testaviva.dev`
- Ingress address: `52.174.78.80`
- TLS secret: `grafana-kristian-tls`

The Grafana pod is the actual running Grafana container. The Deployment keeps the pod running. The Service gives Grafana a stable internal Kubernetes address. The Ingress defines the external HTTP/HTTPS routing rule.

### What is NGINX ingress?

Ingress is a Kubernetes object that defines HTTP and HTTPS routing rules. It says which hostname or path should be sent to which Kubernetes Service.

NGINX ingress controller is the actual software that receives the traffic. It has the Azure LoadBalancer public IP and reads Ingress rules from the cluster.

Confirmed NGINX ingress controller:

- Namespace: `ingress-nginx`
- Service: `ingress-nginx-controller`
- Service type: `LoadBalancer`
- Internal cluster IP: `10.0.92.14`
- Public IP: `52.174.78.80`
- Ports: `80` and `443`

### How does traffic reach the Grafana pod?

The traffic path is:

```text
Browser
-> DNS
-> Azure public IP 52.174.78.80
-> NGINX ingress controller
-> ingress/grafana in namespace grafana-kristian
-> service/grafana on port 80
-> pod/grafana-7674d844ff-j9x64
-> AKS node aks-system-25744230-vmss00000b
```

The Grafana pod is private inside the cluster. Users do not connect directly to the pod. Users connect to the public IP on the NGINX ingress controller, and NGINX forwards traffic through Kubernetes to the Grafana Service and then to the Grafana pod.

### Does DNS point to the NGINX ingress public IP?

Yes.

DNS lookup confirmed:

```text
grafana-kristian.staging.testaviva.dk -> 52.174.78.80
```

The NGINX ingress controller also uses public IP `52.174.78.80`.

This confirms:

```text
grafana-kristian.staging.testaviva.dk
-> 52.174.78.80
-> ingress-nginx-controller
```

One detail to note is that the Kubernetes Ingress host shown in the cluster is `grafana-kristian.testaviva.dev`, while the DNS record checked was `grafana-kristian.staging.testaviva.dk`. The important investigation result is that the checked DNS name points to the same public IP as the NGINX ingress controller.

### What permissions limitation did I hit?

When trying to list cluster nodes with:

```bash
kubectl get nodes -o wide
```

Kubernetes returned a `Forbidden` error because my user does not have permission to list nodes at cluster scope.

This is expected for an intern or limited-access account. I could still inspect namespace-level Grafana resources, services, ingresses, and the Grafana pod placement using:

```bash
kubectl get pods -n grafana-kristian -o wide
```

That command confirmed that the Grafana pod runs on node `aks-system-25744230-vmss00000b`.
