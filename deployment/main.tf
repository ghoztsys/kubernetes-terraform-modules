locals {
  pod_labels = merge({ name = var.name }, var.pod_labels)
}

resource "kubernetes_service" "default" {
  for_each = { for k, v in var.containers : k => v if v.service != null }

  metadata {
    annotations = each.value.service.annotations
    labels      = each.value.service.labels
    name        = each.key
    namespace   = var.namespace
  }

  spec {
    cluster_ip = each.value.service.cluster_ip
    selector   = local.pod_labels
    type       = each.value.service.type

    port {
      name      = each.value.service.port_name
      node_port = each.value.service.node_port
      port      = each.value.port
      protocol  = each.value.service.port_protocol
    }
  }
}

resource "kubernetes_deployment" "default" {
  metadata {
    annotations = var.annotations
    labels      = var.labels
    name        = var.name
    namespace   = var.namespace
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = local.pod_labels
    }

    template {
      metadata {
        labels = local.pod_labels
      }

      spec {
        service_account_name = var.service_account_name

        dynamic "container" {
          for_each = var.containers

          content {
            command           = container.value.command
            image             = container.value.image
            image_pull_policy = container.value.image_pull_policy
            name              = container.key

            dynamic "port" {
              for_each = toset(container.value.port == null ? [] : [container.value.port])

              content {
                container_port = port.value
              }
            }

            dynamic "env" {
              for_each = container.value.env == null ? {} : container.value.env

              content {
                name  = env.key
                value = env.value
              }
            }

            dynamic "volume_mount" {
              for_each = toset(container.value.volume_mount == null ? [] : [container.value.volume_mount])

              content {
                name       = volume_mount.value.name
                mount_path = volume_mount.value.mount_path
              }
            }
          }
        }
      }
    }
  }
}
