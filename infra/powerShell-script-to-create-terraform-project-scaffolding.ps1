# Define Project Root
$ProjectRoot = "terraform-gcp-project"

# Define directories to create
$Folders = @(
    "$ProjectRoot/modules/network",
    "$ProjectRoot/modules/compute",
    "$ProjectRoot/modules/storage",
    "$ProjectRoot/modules/database",
    "$ProjectRoot/modules/iam",
    "$ProjectRoot/envs/dev",
    "$ProjectRoot/envs/staging",
    "$ProjectRoot/envs/production",
    "$ProjectRoot/scripts"
)

# Define files with content
$Files = @{
    "$ProjectRoot/.gitignore" = @"
# Ignore Terraform state files
*.tfstate
*.tfstate.backup
.terraform/
"@
    "$ProjectRoot/provider.tf" = @"
terraform {
  required_version = \">= 1.6.0\"
  required_providers {
    google = {
      source  = \"hashicorp/google\"
      version = \"~> 5.0\"
    }
  }
}

provider \"google\" {
  project = var.project_id
  region  = var.region
}
"@
    "$ProjectRoot/backend.tf" = @"
terraform {
  backend \"gcs\" {
    bucket  = \"my-terraform-state-bucket\"
    prefix  = \"prod/terraform.tfstate\"
  }
}
"@
    "$ProjectRoot/variables.tf" = @"
variable \"project_id\" {
  description = \"GCP project ID\"
  type        = string
}

variable \"region\" {
  description = \"Default region for resources\"
  type        = string
  default     = \"us-central1\"
}
"@
    "$ProjectRoot/main.tf" = @"
module \"network\" {
  source       = \"./modules/network\"
  network_name = \"prod-vpc\"
}
"@
    "$ProjectRoot/modules/network/main.tf" = @"
resource \"google_compute_network\" \"vpc_network\" {
  name                    = var.network_name
  auto_create_subnetworks = false
}
"@
    "$ProjectRoot/modules/network/variables.tf" = @"
variable \"network_name\" {
  description = \"VPC network name\"
  type        = string
}
"@
    "$ProjectRoot/envs/dev/main.tf" = @"
terraform {
  backend \"gcs\" {
    bucket = \"dev-terraform-bucket\"
  }
}
"@
    "$ProjectRoot/envs/staging/main.tf" = @"
terraform {
  backend \"gcs\" {
    bucket = \"staging-terraform-bucket\"
  }
}
"@
    "$ProjectRoot/envs/production/main.tf" = @"
terraform {
  backend \"gcs\" {
    bucket = \"prod-terraform-bucket\"
  }
}
"@
    "$ProjectRoot/README.md" = @"
# Terraform GCP Project

This is a production-ready Terraform setup for GCP.
"@
}

# Create directories
foreach ($folder in $Folders) {
    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }
}

# Create files and add content
foreach ($file in $Files.Keys) {
    if (!(Test-Path $file)) {
        New-Item -ItemType File -Path $file -Force | Out-Null
    }
    Set-Content -Path $file -Value $Files[$file]
}

Write-Host "✅ Terraform project structure created successfully in: $ProjectRoot" -ForegroundColor Green
