terraform {
  backend "s3" {
    bucket = "tfstate-juliusc"
    region = "us-east-1"
    key = "moodindex-state/terraform.tfstate"
  }
}

provider "aws" {
  region = "${var.region}"
}

module "db-tables" {
  source = "../base/db"
  environment_name = "${var.apex_environment}"
}

module "api-gateway" {
  source = "../base/api"
  environment_name = "${var.apex_environment}"
  region = "${var.region}"
  account_id = "${var.account_id}"
}

output "api_url" {
  value = "${module.api-gateway.rest_api_url}"
}
