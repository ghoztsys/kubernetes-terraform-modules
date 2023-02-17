output "deployment" {
  description = "The created Kubernetes Deployment resource."
  value = {
    name      = kubernetes_deployment.default.metadata[0].name
    namespace = kubernetes_deployment.default.metadata[0].namespace
    containers = {
      for container in kubernetes_deployment.default.spec[0].template[0].spec[0].container : container.name => container.image
    }
  }
}

output "services" {
  description = "The created Kubernetes Service resource(s) if applicable."
  value = {
    for k, service in kubernetes_service.default : service.metadata[0].name => {
      namespace = service.metadata[0].namespace
      port      = service.spec[0].port[0].port
      dns = {
        long  = "${service.metadata[0].name}.${service.metadata[0].namespace}.svc.cluster.local:${service.spec[0].port[0].port}"
        short = "${service.metadata[0].name}.${service.metadata[0].namespace}:${service.spec[0].port[0].port}"
        local = "${service.metadata[0].name}:${service.spec[0].port[0].port}"
      }
    }
  }
}
