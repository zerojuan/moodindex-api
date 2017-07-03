provider "aws" {
  region = "${var.region}"
}

module "db_tables" {
  source = "../base/db"
  environment_name = "${var.environment}"
}
