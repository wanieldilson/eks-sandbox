resource "kubernetes_storage_class" "demo" {
  metadata {
    name = "eks-efs"
  }
  storage_provisioner = "eks-sc/eks-efs"
  reclaim_policy      = "Retain"
}

resource "kubernetes_deployment" "example" {
  depends_on = [
      kubernetes_storage_class.demo,
      kubernetes_namespace.demo
  ]
  metadata {
    name = "efs-provisioner"
    namespace = "terraform-prom-graf-namespace"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "efs-provisioner"
      }
    }
    strategy {
      type = "Recreate"
    }
    template {
      metadata {
        labels = {
          app = "efs-provisioner"
        }
      }
      spec {
        automount_service_account_token = true
        container {
          image = "quay.io/external_storage/efs-provisioner:v0.1.0"
          name  = "efs-provisioner"
          env {
            name  = "FILE_SYSTEM_ID"
            value = aws_efs_file_system.demo.id
          }
          env {
            name  = "AWS_REGION"
            value = var.aws_region
          }
          env {
            name  = "PROVISIONER_NAME"
            value = "${kubernetes_storage_class.demo.storage_provisioner}"
          }
          volume_mount {
            name       = "pv-volume"
            mount_path = "/persistentvolumes"
          }
        }
        volume {
          name = "pv-volume"
          nfs {
            server = aws_efs_file_system.demo.dns_name
            path   = "/"
          }
        }
      }
    }
  }
}