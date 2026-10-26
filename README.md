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

## Sealed Secrets Basic Auth

The `/internal/` route is protected with NGINX basic authentication.

Secret flow:

- The plaintext username and password live in a CircleCI context.
- CircleCI generates a temporary `.htpasswd` entry from those values.
- That temporary auth file is used to create a normal Kubernetes `Secret` named `nginx-basic-auth` in namespace `kristian-lab`.
- `kubeseal` encrypts that `Secret` with `sealed-secrets-cert.pem`.
- Only the encrypted `SealedSecret` manifest is committed to Git.

Trust boundaries:

- Plaintext credentials may exist temporarily in CircleCI env vars and short-lived local or CI temp files.
- Plaintext Secret YAML and `.htpasswd` files must never be committed or uploaded.
- The repository may contain only:
  - `kubernetes/nginx-basic-auth-sealedsecret.yaml`
  - `sealed-secrets-cert.pem`
- Only the Sealed Secrets controller running on AKS can decrypt the sealed secret and create the real Kubernetes `Secret`.

Sealing scope:

- The sealed secret is bound to the exact Secret name `nginx-basic-auth`.
- The sealed secret is bound to the exact namespace `kristian-lab`.
- Namespace-wide and cluster-wide sealing are not used.

Rotation:

- Update the basic-auth username or password in the CircleCI context.
- Generate a new temporary `.htpasswd` file.
- Create and seal a new `nginx-basic-auth` secret for `kristian-lab`.
- Commit the updated encrypted manifest and deploy it.
- After rollout, the old password must no longer work.

Troubleshooting:

- `401 Unauthorized` on `/internal/` without credentials is expected.
- `200 OK` on `/internal/` with the correct credentials is expected.
- If authentication does not work, check:
  - the `SealedSecret` name is `nginx-basic-auth`
  - the namespace is `kristian-lab`
  - the Deployment mounts the secret at `/etc/nginx/auth`
  - NGINX points to `/etc/nginx/auth/.htpasswd`
  - the sealed secret was created with the current controller public certificate
  - no plaintext credential files were committed by mistake

## Safety boundaries

- Azure subscription: StagingCSP
- Lab resource group: rg-kristian-devops-lab
- Existing AKS cluster: kubernetes
- Existing AKS resource group: kubernetes-stg
- Intern namespace: kristian-lab
- Never commit credentials, kubeconfig, Terraform state, or plan files.
- Never run delete or destroy commands.
- Every Terraform plan must be reviewed before apply.
