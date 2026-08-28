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

## CircleCI

CircleCI uses `.circleci/config.yml` from this repository.

Inspect a failed job:

1. Open the pull request in GitHub.
2. Open the CircleCI check.
3. Open the failed job.
4. Read the failed step log to see which command returned an error.

Local equivalent of the CircleCI smoke test:

```bash
docker build -t kristian-web:1.0.0 .
docker run --rm -d --name kristian-web -p 8080:8080 kristian-web:1.0.0
curl http://localhost:8080
curl http://localhost:8080/healthz
docker rm -f kristian-web
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
