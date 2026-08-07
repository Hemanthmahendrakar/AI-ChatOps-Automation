terraform {
  backend "s3" {
    bucket = "ai-infrastructure-terraform-state"
    key    = "terraform/state.tfstate"
    region = "us-east-1"
  }
}
