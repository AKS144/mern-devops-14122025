# terraform {
#   required_providers { kubernetes = { source = "hashicorp/kubernetes" } }
# }
# provider "kubernetes" {
#   # Uses KUBECONFIG env var from Jenkins
# }
# resource "kubernetes_namespace_v1" "mern_ns" {
#   metadata { name = "mern-namespace" }
# }


terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

# --- THIS WAS MISSING ---
variable "kube_config" {
  type = string
}
# ------------------------

provider "kubernetes" {
  config_path = var.kube_config
}

resource "kubernetes_namespace_v1" "mern_ns" {
  metadata {
    name = "mern-namespace"
  }
}