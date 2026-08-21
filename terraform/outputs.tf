output "database_project_ref" {
  value = supabase_project.db.id
}

output "backend_url" {
  value = local.backend_url
}

output "frontend_url" {
  value = local.frontend_url
}

output "landing_url" {
  value = "https://${data.netlify_site.landing.name}.netlify.app"
}