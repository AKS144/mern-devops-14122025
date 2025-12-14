terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
  # This matches the file we generated in Jenkinsfile
  config_path = "/var/jenkins_home/workspace/MERN-Deploy/k8s-config-fixed"
}

resource "kubernetes_namespace" "mern_ns" {
  metadata {
    name = "mern-namespace"
  }
}