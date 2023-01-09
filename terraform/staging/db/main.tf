provider "aws" {
  region = "eu-central-1"

}

terraform {
  backend "s3" {
    bucket         = "reactlambda-terraform"
    key            = "staging/db/terraform.tfstate"
    region         = "eu-central-1"

    
    dynamodb_table = "reactlambda-terraform"
    encrypt        = true
  }
}

module "db" {
  source = "../../modules/db"

  stage_name       = "staging"
}

