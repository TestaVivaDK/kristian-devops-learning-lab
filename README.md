# Kristian DevOps Learning Lab

Beginner project for learning GitHub, Terraform, Azure, and Kubernetes.

## Safety boundaries

- Azure subscription: StagingCSP
- Lab resource group: rg-kristian-devops-lab
- Existing AKS cluster: kubernetes
- Existing AKS resource group: kubernetes-stg
- Intern namespace: kristian-lab
- Never commit credentials, kubeconfig, Terraform state, or plan files.
- Never run delete or destroy commands.
- Every Terraform plan must be reviewed before apply.