// Access Policies
resource "aws_dynamodb_table" "access-policies-table" {
  name = "AccessPolicies"
  hash_key = "userType"
  range_key = "id"
  read_capacity = "${var.read_capacity}"
  write_capacity = "${var.write_capacity}"
  attribute {
    name = "userType"
    type = "S"
  }
  attribute {
    name = "id"
    type = "S"
  }

  tags {
    ENVIRONMENT = "moodindex-api"
  }
}

// Users Table
resource "aws_dynamodb_table" "users-table" {
  name = "Users"
  hash_key = "id"
  read_capacity = "${var.read_capacity}"
  write_capacity = "${var.write_capacity}"
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
    write_capacity = "${var.write_capacity}"
    read_capacity = "${var.read_capacity}"
    projection_type = "INCLUDE"
    non_key_attributes = [ "password" ]
  }

  tags {
    ENVIRONMENT = "moodindex-api"
  }
}

// Mood Table
resource "aws_dynamodb_table" "moods-table" {
  name = "Moods"
  hash_key = "ownerId"
  range_key = "created"
  read_capacity = "${var.read_capacity}"
  write_capacity = "${var.write_capacity}"
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
    write_capacity = "${var.write_capacity}"
    read_capacity = "${var.read_capacity}"
    projection_type = "KEYS_ONLY"
  }

  tags {
    ENVIRONMENT = "moodindex-api"
  }
}

// Mood Reacts Table
resource "aws_dynamodb_table" "reacts-table" {
  name = "Reacts"
  hash_key = "id"
  range_key = "ownerId"
  read_capacity = "${var.read_capacity}"
  write_capacity = "${var.write_capacity}"
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
    ENVIRONMENT = "moodindex-api"
  }
}
