resource "kubernetes_persistent_volume_claim" "yace_pvc" {
  depends_on = [
    kubernetes_namespace.demo,
  ]
  metadata {
    name      = "tf-yace-pvc"
    annotations = {
      "volume.beta.kubernetes.io/storage-class" = "eks-efs"
    }
    namespace = "terraform-prom-graf-namespace"
    labels = {
      vol = "yace_store_pvc"
    }
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}

#configMap 
resource "kubernetes_config_map" "yace_configmap" {
  depends_on = [
    kubernetes_persistent_volume_claim.yace_pvc,
  ]

  metadata {
    name      = "tf-yace-configmap"
    namespace = "terraform-prom-graf-namespace"
  }
  data = {
    "config.yml" = "${file("config-files/config.yml")}"

  }
}

#deployment
resource "kubernetes_deployment" "yace_deploy" {
  depends_on = [
    kubernetes_config_map.yace_configmap,
  ]
  metadata {
    name      = "tf-yace-deployment-new"
    namespace = "terraform-prom-graf-namespace"
    labels = {
      "exporter" = "yace"
    }
  }

  spec {
    selector {
      match_labels = {
        "exporter" = "yace"
      }
    }
    replicas = 1
  
    template {
      metadata {
        labels = {
          name = "yace"
          exporter = "yace"
        }
      }
      spec {
        container {
          name  = "yace"
          image = "quay.io/invisionag/yet-another-cloudwatch-exporter:v0.24.0-alpha"
          image_pull_policy = "IfNotPresent"
          args  = ["--config.file=config-files/config.yml"]
          env {
            name = "AWS_ACCESS_KEY_ID"
            value = var.aws_access_key
          }
          env {
            name = "AWS_SECRET_ACCESS_KEY"
            value = var.aws_secret_key
          }
          port {
            container_port = 5000
          }
          volume_mount {
            name       = "config-volume"
            mount_path = "/config.yml"
            sub_path = "config.yml"
          }
          
        }
        volume {
          name = "config-volume"
          config_map {
            name = "tf-yace-configmap"
          }
        }
        
      }
    }
  }
}

# service 
resource "kubernetes_service" "yace_svc" {
  depends_on = [
    kubernetes_deployment.yace_deploy,
  ]
  metadata {
    name      = "tf-yace-svc"
    namespace = "terraform-prom-graf-namespace"
  }
  spec {
    selector = {
      exporter = kubernetes_deployment.yace_deploy.metadata.0.labels.exporter
    }
    port {
      port        = 5000
      target_port = 5000
    }
    type = "LoadBalancer"
  }
}


output "yace" {
  value = "${kubernetes_service.yace_svc.load_balancer_ingress[0].hostname}:5000"
  
}

