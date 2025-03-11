terraform {
  backend \"gcs\" {
    bucket = \"staging-terraform-bucket\"
  }
}
