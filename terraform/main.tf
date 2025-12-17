terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

# Define a variable that Jenkins will fill in
variable "kube_config" {
  type = string
}

provider "kubernetes" {
  # Explicitly use the variable
  config_path = var.kube_config
}

resource "kubernetes_namespace" "mern_ns" {
  metadata {
    name = "mern-namespace"
  }
}