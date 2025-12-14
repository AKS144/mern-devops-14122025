terraform {
  required_providers {
    kubernetes = { source = "hashicorp/kubernetes" }
  }
}
provider "kubernetes" {
  config_path = "/var/jenkins_home/.kube/config" # Path inside Jenkins
}
resource "kubernetes_namespace" "mern_ns" {
  metadata { name = "mern-namespace" }
}