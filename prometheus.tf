# pvc
resource "kubernetes_persistent_volume_claim" "prom_pvc" {
  depends_on = [
    kubernetes_namespace.demo,
  ]
  metadata {
    name      = "tf-prometheus-pvc"
    annotations = {
      "volume.beta.kubernetes.io/storage-class" = "eks-efs"
    }
    namespace = "terraform-prom-graf-namespace"
    labels = {
      vol = "prom_store_pvc"
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
resource "kubernetes_config_map" "prom_configmap" {
  depends_on = [
    kubernetes_persistent_volume_claim.prom_pvc,
  ]
  metadata {
    name      = "tf-prometheus-configmap"
    namespace = "terraform-prom-graf-namespace"
  }
  data = {
    "prometheus.yml" = "${file("config-files/prometheus.yml")}"
   
  }
}

#deployment
resource "kubernetes_deployment" "prom_deploy" {
  depends_on = [
    kubernetes_config_map.prom_configmap,
  ]
  metadata {
    name      = "tf-prometheus-deployment"
    namespace = "terraform-prom-graf-namespace"
    labels = {
      env = "metrics"
    }
  }
  spec {
    selector {
      match_labels = {
        env = "metrics"
      }
    }
    template {
      metadata {
        labels = {
          env = "metrics"
        }
      }

      spec {
        container {
          name  = "prometheus"
          image = "prom/prometheus:v2.20.1"
          args  = ["--config.file=config-files/prometheus.yml"]
          port {
            container_port = 9090
          }
          volume_mount {
            name       = "prometheus-persistent-storage-store"
            mount_path = "prometheus_data/"
          }
          volume_mount {
            name       = "prometheus-script"
            mount_path = "/prometheus.yml"
            sub_path   = "prometheus.yml"
          }
        }
        volume {
          name = "prometheus-script"
          config_map {
            name = "tf-prometheus-configmap"
          }
        }
        volume {
          name = "prometheus-persistent-storage-store"
          persistent_volume_claim {
            claim_name = "tf-prometheus-pvc"
          }
        }
      }
    }
  }
}

# service 
resource "kubernetes_service" "prom_svc" {
  depends_on = [
    kubernetes_deployment.prom_deploy,
  ]
  metadata {
    name      = "tf-prometheus-svc"
    namespace = "terraform-prom-graf-namespace"
  }
  spec {
    selector = {
      env = kubernetes_deployment.prom_deploy.metadata.0.labels.env
    }
    port {
      port        = 9090
      target_port = 9090
    }
    type = "LoadBalancer"
  }
}

output "prometheus" {
   value = "${kubernetes_service.prom_svc.load_balancer_ingress[0].hostname}:9090"
}