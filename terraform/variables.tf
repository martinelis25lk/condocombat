variable "dockerhub_username" {
  type        = string
  description = "Usuário do DockerHub onde as imagens foram publicadas no Desafio 2."
}

# --- Supabase ---
variable "supabase_access_token" {
  type      = string
  sensitive = true
}

variable "supabase_organization_id" {
  type        = string
  description = "Slug da organização Supabase."
}

variable "supabase_db_password" {
  type      = string
  sensitive = true
}

# --- Render ---
variable "render_api_key" {
  type      = string
  sensitive = true
}

variable "render_owner_id" {
  type      = string
  sensitive = true
}

variable "render_region" {
  type    = string
  default = "oregon"
}

variable "render_plan" {
  type    = string
  default = "free"
}

# --- Backend ---
variable "backend_secret_key" {
  type      = string
  sensitive = true
}

# --- Netlify ---
variable "netlify_api_token" {
  type      = string
  sensitive = true
}

variable "netlify_site_name" {
  type    = string
  default = "condocombat-landing-gui"
}


variable "netlify_team_slug" {
  type        = string
  description = "Slug do seu team/workspace na Netlify."
  default     = "martinelis25lk"
}