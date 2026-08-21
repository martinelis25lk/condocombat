# O site já existe na Netlify (condocombat-landing-gui) — usamos "data" para
# referenciá-lo, não "resource" (não é o Terraform que cria o site).
data "netlify_site" "landing" {
  name = var.netlify_site_name
}

# Aponta a Landing Page pra URL pública do Frontend (Render)
resource "netlify_environment_variable" "landing_public_app_url" {
  site_id = data.netlify_site.landing.id
  team_id = var.netlify_team_id
  key     = "PUBLIC_APP_URL"
  scopes  = ["builds"]
  values = [
    {
      context = "all"
      value   = local.frontend_url
    }
  ]
}

# Deploy do landing/dist via Netlify CLI, disparado dentro do terraform apply.
resource "terraform_data" "landing_deploy" {
  triggers_replace = [
    data.netlify_site.landing.id,
    local.frontend_url,
    filesha256("${path.module}/../landing/dist/index.html"),
  ]

  provisioner "local-exec" {
    command     = "npx --yes netlify-cli deploy --dir=dist --prod --auth=$NETLIFY_AUTH_TOKEN --site=$NETLIFY_SITE_ID"
    working_dir = "${path.module}/../landing"
    environment = {
      NETLIFY_AUTH_TOKEN = var.netlify_api_token
      NETLIFY_SITE_ID    = data.netlify_site.landing.id
    }
  }

  depends_on = [netlify_environment_variable.landing_public_app_url]
}