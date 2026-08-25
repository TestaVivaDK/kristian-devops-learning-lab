locals {
  common_tags = {
    environment = "learning"
    owner       = var.owner
    managed_by  = "terraform"
    project     = "devops-learning-lab"
  }
}