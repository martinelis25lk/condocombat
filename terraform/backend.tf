# Backend e Frontend precisam, cada um, da URL pública do outro (CORS_ORIGINS
# e NEXT_PUBLIC_API_URL). Para evitar dependência circular entre os dois
# render_web_service, montamos as URLs a partir do padrão previsível do Render
# (https://<nome-do-serviço>.onrender.com).
locals {
  backend_url  = "https://condocombat-backend-api.onrender.com"
  frontend_url = "https://condocombat-frontend-web.onrender.com"
}

resource "render_web_service" "backend" {
  name              = "condocombat-backend-api"
  plan              = var.render_plan
  region            = var.render_region
  health_check_path = "/health"

   runtime_source = {
    image = {
      image_url = "docker.io/${var.dockerhub_username}/condocombat-backend"
      tag       = "latest"
    }
  }

  env_vars = {
    DATABASE_URL = {
      value = local.database_url
    }
    SECRET_KEY = {
      value = var.backend_secret_key
    }
    CORS_ORIGINS = {
      value = local.frontend_url
    }
  }
}