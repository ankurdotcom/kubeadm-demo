terraform {
  backend \"gcs\" {
    bucket = \"prod-terraform-bucket\"
  }
}
