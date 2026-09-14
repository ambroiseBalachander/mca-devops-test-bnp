resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = "mca-cluster"
  machine_type     = "controlplane"
  cluster_endpoint = "https://${local.cp1_ip}:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_machine_configuration" "worker" {
  cluster_name     = "mca-cluster"
  machine_type     = "worker"
  cluster_endpoint = "https://${local.cp1_ip}:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

resource "talos_machine_configuration_apply" "cp1" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                         = local.cp1_ip
  depends_on                   = [incus_instance.talos_cp1]
}

resource "talos_machine_configuration_apply" "worker1" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                         = local.worker1_ip
  depends_on                   = [incus_instance.talos_worker1]
}

resource "talos_machine_configuration_apply" "worker2" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                         = local.worker2_ip
  depends_on                   = [incus_instance.talos_worker2]
}

resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                  = local.cp1_ip
  depends_on            = [talos_machine_configuration_apply.cp1]
}

data "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                  = local.cp1_ip
  depends_on            = [talos_machine_bootstrap.this]
}

data "talos_client_configuration" "this" {
  cluster_name         = "mca-cluster"
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [local.cp1_ip]
  nodes                = [local.cp1_ip]
}

resource "local_file" "kubeconfig" {
  content  = data.talos_cluster_kubeconfig.this.kubeconfig_raw
  filename = "/home/bala/talos-cluster/kubeconfig"
}

resource "local_file" "talosconfig" {
  content  = data.talos_client_configuration.this.talos_config
  filename = "/home/bala/talos-cluster/talosconfig"
}