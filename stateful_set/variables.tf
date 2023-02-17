variable "name" {
  default     = null
  description = "Name of the StatefulSet resource."
  nullable    = true
  type        = string
}

variable "namespace" {
  default     = null
  description = "Namespace to create the StatefulSet and associated Service resources in."
  type        = string
}

variable "replicas" {
  default     = 1
  description = "Number of desired replicas."
  type        = number
}

variable "revision_history_limit" {
  default     = 10
  description = "Maximum number of revisions that will be maintained in the StatefulSet's revision history"
  type        = number
}

variable "service_name" {
  description = "Name of the Service that governs this StatefulSet and is responsible for the network identity of the set."
  type        = string
}

variable "annotations" {
  default     = {}
  description = "Annotations to attach to the StatefulSet resource."
  type        = map(string)
}

variable "labels" {
  default     = {}
  description = "Labels to attach to the StatefulSet resource."
  type        = map(string)
}

variable "pod_annotations" {
  default     = {}
  description = "Annotations to attach to each pod in the StatefulSet."
  type        = map(string)
}

variable "pod_labels" {
  default     = {}
  description = "Labels to attach to each pod in the StatefulSet."
  type        = map(string)
}

variable "pod_management_policy" {
  default     = "OrderedReady"
  description = "Controls how pods are created during initial scale up, when replacing pods on nodes, or when scaling down."
  type        = string
}

variable "storage_class" {
  default     = null
  description = "Configuration for one storage class to be used by the set."
  nullable    = true
  type = object({
    annotations = optional(map(string), {})
    labels      = optional(map(string), {})
    name        = string
    parameters  = optional(map(string))
    provisioner = string
  })
}

variable "volume_claim" {
  default     = null
  description = "Configuration for one PersistentVolumeClaim resource attached to this set (see https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/stateful_set#specvolume_claim_template)."
  nullable    = true
  type = object({
    access_modes = optional(list(string), ["ReadWriteOnce"])
    annotations  = optional(map(string), {})
    labels       = optional(map(string), {})
    name         = string
    storage      = string
  })
}

variable "containers" {
  default     = {}
  description = "Configuration of containers within the set (see https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/stateful_set#spec)."
  type = map(object({
    command           = optional(list(string))
    env               = optional(map(string))
    image             = string
    image_pull_policy = optional(string)
    port              = optional(number)
    service = optional(object({
      annotations   = optional(map(string), {})
      cluster_ip    = optional(string)
      labels        = optional(map(string), {})
      node_port     = optional(number)
      port_name     = optional(string)
      port_protocol = optional(string, "TCP")
      type          = optional(string, "ClusterIP")
    }))
    volume_mount = optional(object({
      mount_path = string
      name       = string
    }))
  }))
}
