terraform {
  backend "s3" {
    bucket       = "react-js-application-terraform-state-866934333672"
    key          = "task-tracking-app/production/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
