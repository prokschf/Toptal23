provider "aws" {
  region = "eu-central-1"

}

terraform {
  backend "s3" {
    bucket         = "reactlambda-terraform"
    key            = "staging/services/terraform.tfstate"
    region         = "eu-central-1"

    
    dynamodb_table = "reactlambda-terraform"
    encrypt        = true
  }
}

module "frontend" {
  source = "../../../modules/services/frontend"

  stage_name       = "staging"
}