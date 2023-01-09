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

module "backend" {
  source = "../../../modules/services/backend"

  stage_name       = "staging"
}