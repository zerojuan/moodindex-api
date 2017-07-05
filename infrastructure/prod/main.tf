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
  alias = "${var.apex_environment}"
  account_id = "${var.account_id}"
}
