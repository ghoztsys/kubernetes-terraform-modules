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

resource "kubernetes_storage_class" "default" {
  count = var.storage_class == null ? 0 : 1

  storage_provisioner = var.storage_class.provisioner
  parameters          = var.storage_class.parameters

  metadata {
    annotations = var.storage_class.annotations
    labels      = var.storage_class.labels
    name        = var.storage_class.name
  }
}

resource "kubernetes_stateful_set" "default" {
  metadata {
    name        = var.name
    namespace   = var.namespace
    labels      = var.labels
    annotations = var.annotations
  }

  spec {
    pod_management_policy  = var.pod_management_policy
    replicas               = var.replicas
    revision_history_limit = var.revision_history_limit
    service_name           = var.service_name

    selector {
      match_labels = local.pod_labels
    }

    template {
      metadata {
        annotations = var.pod_annotations
        labels      = local.pod_labels
      }

      spec {
        automount_service_account_token = true
        service_account_name            = var.service_account_name

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
                mount_path = volume_mount.value.mount_path
                name       = volume_mount.value.name
              }
            }
          }
        }
      }
    }

    dynamic "volume_claim_template" {
      for_each = toset(var.volume_claim == null ? [] : [var.volume_claim])

      content {
        metadata {
          annotations = merge(var.storage_class == null ? {} : {
            "volume.beta.kubernetes.io/storage-class" = kubernetes_storage_class.default[0].metadata[0].name
          }, var.volume_claim.annotations)
          labels = merge({ name = volume_claim_template.value.name }, var.volume_claim.labels)
          name   = volume_claim_template.value.name
        }

        spec {
          access_modes = volume_claim_template.value.access_modes

          resources {
            requests = {
              storage = volume_claim_template.value.storage
            }
          }
        }
      }
    }
  }
}
