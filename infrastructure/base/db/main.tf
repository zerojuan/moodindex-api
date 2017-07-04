// Access Policies
resource "aws_dynamodb_table" "access-policies-table" {
  name = "${var.environment_name}AccessPolicies"
  hash_key = "userType"
  range_key = "id"
  read_capacity = "10"
  write_capacity = "10"
  attribute {
    name = "userType"
    type = "S"
  }
  attribute {
    name = "id"
    type = "S"
  }

  tags {
    ENVIRONMENT = "${var.environment_name}"
  }
}

// Users Table
resource "aws_dynamodb_table" "users-table" {
  name = "${var.environment_name}Users"
  hash_key = "id"
  read_capacity = "10"
  write_capacity = "10"
  attribute {
    name = "id"
    type = "S"
  }
  attribute {
    name = "username"
    type = "S"
  }

  global_secondary_index {
    name = "usernameIndex"
    hash_key = "username"
    write_capacity = "10"
    read_capacity = "10"
    projection_type = "INCLUDE"
    non_key_attributes = [ "password" ]
  }

  tags {
    ENVIRONMENT = "${var.environment_name}"
  }
}

// Mood Table
resource "aws_dynamodb_table" "moods-table" {
  name = "${var.environment_name}Moods"
  hash_key = "ownerId"
  range_key = "created"
  read_capacity = "10"
  write_capacity = "10"
  attribute {
    name = "ownerId"
    type = "S"
  }
  attribute {
    name = "created"
    type = "S"
  }
  attribute {
    name = "value"
    type = "N"
  }

  global_secondary_index {
    name = "valueIndex"
    hash_key = "value"
    write_capacity = "10"
    read_capacity = "10"
    projection_type = "KEYS_ONLY"
  }

  tags {
    ENVIRONMENT = "${var.environment_name}"
  }
}

// Mood Reacts Table
resource "aws_dynamodb_table" "reacts-table" {
  name = "${var.environment_name}Reacts"
  hash_key = "id"
  range_key = "ownerId"
  read_capacity = "10"
  write_capacity = "10"
  attribute {
    name = "id"
    type = "S"
  }
  attribute {
    name = "ownerId"
    type = "S"
  }
  attribute {
    name = "value"
    type = "N"
  }

  local_secondary_index {
    name = "valueIndex"
    range_key = "value"
    projection_type = "KEYS_ONLY"
  }

  tags {
    ENVIRONMENT = "${var.environment_name}"
  }
}
