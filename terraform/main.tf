terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

variable "kube_config" {
  type = string
}

provider "kubernetes" {
  config_path = var.kube_config
}

# We use "mern_namespace" as the terraform ID, but "mern-namespace" as the actual K8s name
resource "kubernetes_namespace_v1" "mern_ns" {
  metadata {
    name = "mern-namespace"
  }
}