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
