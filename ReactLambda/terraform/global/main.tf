terraform {
  backend "s3" {
    bucket         = "terraform-reactlambda"
    key            = "global/terraform.tfstate"
    region         = "eu-central-1"

    
    dynamodb_table = "terraform-reactlambda"
    encrypt        = true
  }
}