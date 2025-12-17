terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
  # No config_path needed! 
  # Terraform will automatically find ~/.kube/config inside Jenkins.
}

resource "kubernetes_namespace" "mern_ns" {
  metadata {
    name = "mern-namespace"
  }
}