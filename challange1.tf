#three-tier architecture with Cloud Run as the frontend and backend, and Cloud SQL as the database on GCP

# Define provider and variables


provider "google" {
  credentials = file("./credentials.json")
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "The ID of the GCP project"
  default = "sandbox-durgesh"
}

variable "region" {
  description = "The region to deploy resources"
  default = "us-central1"
}

# Define the Cloud SQL instance
resource "google_sql_database_instance" "my_db_instance" {
  name             = "test_db1"
  region           = var.region
  database_version = "POSTGRES_13"

  settings {
    tier = "db-f1-micro"

    # Set maintenance window to avoid disrupting service
    maintenance_window {
      day  = 1
      hour = 0
    }
  }
}

# put the Cloud SQL database
resource "google_sql_database" "my_test_database" {
  name     = "my--test-database"
  instance = google_sql_database_instance.my_db_instance.name
}

# put the Cloud Run service for the frontend
resource "google_cloud_run_service" "frontend" {
  name     = "frontend-service"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/frontend:latest"
        env   = {
          # Set environment variables for the frontend service
          DATABASE_URL = google_sql_database.my_test_database.connection_name
        }
      }
    }
  }
}

# Define the Cloud Run service for the backend
resource "google_cloud_run_service" "backend" {
  name     = "backend-service"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/backend:latest"
        env   = {
          # Set environment variables for the backend service
          DATABASE_URL = google_sql_database.my_test_database.connection_name
        }
      }
    }
  }
}


#Create a new GCP project or use an existing one.
#Enable the required APIs: Cloud Run, Cloud SQL Admin, and Compute Engine.
#Create a service account and grant it the required permissions for creating resources in your project.
#Initialize the Terraform project by running terraform init in the directory where the main.tf file is located.
#Set the values of the project_id and region variables in a terraform.tfvars file.
