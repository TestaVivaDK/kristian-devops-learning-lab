locals {
  common_tags = {
    environment = "lab"
    owner = var.owner
    managed_by = "terraform"
    project = "kristian-devops-learning-lab"
    training_phase = "update-practice"
  }
}