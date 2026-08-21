
import {
  to = supabase_project.db
  id = "nimlgkmxqjbuenizzuna"
}

resource "supabase_project" "db" {
  organization_id   = var.supabase_organization_id
  name              = "martinelis25lk's Project"
  database_password = var.supabase_db_password
  region            = "us-east-2" # ajuste conforme o passo abaixo

  lifecycle {
    ignore_changes = [database_password, name, region]
  }
}

# Monta a DATABASE_URL no formato exigido pelo backend (SQLAlchemy async + asyncpg)
locals {
  database_url = "postgresql+asyncpg://postgres:${var.supabase_db_password}@db.${supabase_project.db.id}.supabase.co:5432/postgres"
}