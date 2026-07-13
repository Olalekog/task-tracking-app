locals {
  rendered_manifest_dir = "${path.module}/generated/k8s"
}

resource "local_file" "backend_deployment_manifest" {
  filename = "${local.rendered_manifest_dir}/backend-deployment.yaml"
  content = templatefile("${path.module}/templates/backend-deployment.yaml.tftpl", {
    backend_image_url = var.backend_image_url
  })
}

resource "local_file" "frontend_deployment_manifest" {
  filename = "${local.rendered_manifest_dir}/frontend-deployment.yaml"
  content = templatefile("${path.module}/templates/frontend-deployment.yaml.tftpl", {
    frontend_image_url = var.frontend_image_url
  })
}
