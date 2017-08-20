terraform {
  backend "s3" {
    bucket = "tfstate-juliusc"
    region = "us-west-2"
    key = "moodindex-state/terraform.tfstate"
  }
}

provider "aws" {
  region = "${var.region}"
}

# TODO: use S3 to store state
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
