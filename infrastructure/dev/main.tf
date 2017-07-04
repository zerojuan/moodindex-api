provider "aws" {
  region = "${var.region}"
}

module "db-tables" {
  source = "../base/db"
  environment_name = "${var.environment}"
}

module "api-gateway" {
  source = "../base/api"
  environment_name = "${var.environment}"
  region = "${var.region}"
  account_id = "${var.account_id}"
}
