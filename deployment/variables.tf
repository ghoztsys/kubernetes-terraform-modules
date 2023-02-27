variable "annotations" {
  default     = {}
  description = "Annotations to attach to the Deployment resource."
  type        = map(string)
}

variable "containers" {
  default     = {}
  description = "Configuration of containers within the Deployment (see https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment#container)."
  type = map(object({
    command           = optional(list(string))
    env               = optional(map(string))
    image             = string
    image_pull_policy = optional(string)
    port              = optional(number)
    service = optional(object({
      annotations   = optional(map(string), {})
      cluster_ip    = optional(string)
      labels        = optional(map(string))
      node_port     = optional(number)
      port_name     = optional(string)
      port_protocol = optional(string)
      type          = string
    }))
    volume_mount = optional(object({
      mount_path = string
      name       = string
    }))
  }))
}

variable "labels" {
  default     = {}
  description = "Labels to attach to the Deployment resource."
  type        = map(string)
}

variable "name" {
  default     = null
  description = "Name of the Deployment resource."
  nullable    = true
  type        = string
}

variable "namespace" {
  default     = null
  description = "Namespace to create the Deployment and associated Service resources in."
  nullable    = true
  type        = string
}

variable "pod_labels" {
  default     = {}
  description = "Labels to attach to each pod in the Deployment."
  type        = map(string)
}

variable "replicas" {
  default     = 1
  description = "Number of desired replicas."
  type        = number
}

variable "service_account_name" {
  default     = null
  description = "Name of the ServiceAccount to use to run the pods."
  nullable    = true
  type        = string
}
