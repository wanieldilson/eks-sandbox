
output "demo" {
    value = aws_efs_file_system.demo
}

resource "kubernetes_namespace" "demo" {
  metadata {
    name = "terraform-prom-graf-namespace"
  }

}

resource "kubernetes_cluster_role_binding" "demo" {
  depends_on = [
    kubernetes_namespace.demo
  ]
  metadata {
    name = "nfs-provisioner-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "terraform-prom-graf-namespace"
  }
}