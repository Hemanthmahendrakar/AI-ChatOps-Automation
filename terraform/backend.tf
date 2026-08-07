terraform {
  backend "s3" {
    bucket = "hk-ai-infrastructure-terraform-state"
    key    = "terraform/state.tfstate"
    region = "us-east-1"
  }
}
