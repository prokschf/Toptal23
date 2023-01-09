provider "aws" {
  region = "eu-central-1"

}

terraform {
  backend "s3" {
    bucket         = "reactlambda-terraform"
    key            = "staging/services/frontend/terraform.tfstate"
    region         = "eu-central-1"

    
    dynamodb_table = "reactlambda-terraform"
    encrypt        = true
  }
}

module "frontend" {
  source = "../../../modules/services/frontend"

  bucket_name       = "ReactLambda-frontend-staging-www"
}

data "terraform_remote_state" "backend" {
  backend = "s3"

  config = {
    bucket = "reactlambda-terraform"
    key    = "staging/services/terraform.tfstate"
    region = "eu-central-1"
  }
}