resource "kubernetes_namespace" "mca_app" {
  metadata {
    name = "mca-app"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

resource "kubernetes_secret" "postgres_credentials" {
  metadata {
    name      = "postgres-app-credentials"
    namespace = kubernetes_namespace.mca_app.metadata[0].name
  }
  data = {
    username = "myapplication"
    password = "M3P@ssw0rd!"
  }
}

data "http" "local_path_yaml" {
  url = "https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml"
}

resource "kubectl_manifest" "local_path_provisioner" {
  for_each  = { for i, doc in split("---", data.http.local_path_yaml.response_body) : i => doc if trimspace(doc) != "" }
  yaml_body = each.value
}

resource "null_resource" "set_default_storageclass" {
  depends_on = [kubectl_manifest.local_path_provisioner]

  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG=/home/bala/talos-cluster/kubeconfig
      kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
    EOT
  }
}

resource "null_resource" "cnpg_operator" {
  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG=/home/bala/talos-cluster/kubeconfig
      kubectl apply --server-side -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.1.yaml
    EOT
  }
}

resource "kubectl_manifest" "postgres_cluster" {
  yaml_body = <<-YAML
    apiVersion: postgresql.cnpg.io/v1
    kind: Cluster
    metadata:
      name: postgres
      namespace: mca-app
    spec:
      instances: 2
      imageName: ghcr.io/cloudnative-pg/postgresql:17.2
      resources:
        requests:
          memory: "512Mi"
          cpu: "500m"
        limits:
          memory: "1Gi"
          cpu: "1"
      affinity:
        podAntiAffinityType: required
      monitoring:
        enablePodMonitor: true
      storage:
        size: 2Gi
        storageClass: local-path
      bootstrap:
        initdb:
          database: myapplication
          owner: myapplication
          secret:
            name: postgres-app-credentials
  YAML

  depends_on = [
    kubernetes_secret.postgres_credentials,
    kubectl_manifest.local_path_provisioner,
    null_resource.set_default_storageclass,
    null_resource.cnpg_operator
  ]
}

resource "kubectl_manifest" "postgres_pooler" {
  yaml_body = <<-YAML
    apiVersion: postgresql.cnpg.io/v1
    kind: Pooler
    metadata:
      name: postgres-pooler
      namespace: mca-app
    spec:
      cluster:
        name: postgres
      instances: 2
      type: rw
      pgbouncer:
        poolMode: transaction
        parameters:
          max_client_conn: "200"
          default_pool_size: "20"
  YAML

  depends_on = [kubectl_manifest.postgres_cluster]
}