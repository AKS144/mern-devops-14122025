terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
  # We will generate this specific file in the Jenkins pipeline
  config_path = "/var/jenkins_home/workspace/k8s-config-fixed"
}

resource "kubernetes_namespace" "mern_ns" {
  metadata {
    name = "mern-namespace"
  }
}