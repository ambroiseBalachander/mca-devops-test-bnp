terraform {
  required_providers {
    kubectl = {
      source = "alekc/kubectl"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    http = {
      source = "hashicorp/http"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path = "/home/bala/talos-cluster/kubeconfig"
  }
}

provider "kubectl" {
  config_path = "/home/bala/talos-cluster/kubeconfig"
}

provider "kubernetes" {
  config_path = "/home/bala/talos-cluster/kubeconfig"
}