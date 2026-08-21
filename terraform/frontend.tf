resource "render_web_service" "frontend" {
  name   = "condocombat-frontend-web"
  plan   = var.render_plan
  region = var.render_region

  runtime_source = {
    image = {
      image_url = "docker.io/${var.dockerhub_username}/condocombat-frontend"
      tag       = "latest"
    }
  }

  env_vars = {
    NEXT_PUBLIC_API_URL = {
      value = local.backend_url
    }
  }
}