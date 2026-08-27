# Kristian DevOps Learning Lab

Beginner project for learning GitHub, Terraform, Azure, and Kubernetes.

## Docker Compose

Start the website:

```bash
docker compose up -d
```

View logs:

```bash
docker compose logs
```

Test the site:

```bash
curl http://localhost:8080
curl http://localhost:8080/healthz
docker compose ps
```

Stop the site:

```bash
docker compose down
```

## Safety boundaries

- Azure subscription: StagingCSP
- Lab resource group: rg-kristian-devops-lab
- Existing AKS cluster: kubernetes
- Existing AKS resource group: kubernetes-stg
- Intern namespace: kristian-lab
- Never commit credentials, kubeconfig, Terraform state, or plan files.
- Never run delete or destroy commands.
- Every Terraform plan must be reviewed before apply.
