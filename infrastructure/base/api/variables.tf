variable "environment_name" {}

variable "region" {}

variable "account_id" {}

variable "request_parameters" {
  default = {
    "method.request.header.Authorization" = true
  }
}

variable "deployment_description" {
  default = "Auto deploy"
}

variable "alias" {
  default = "current"
}

variable "list_mood_lambda" {
  default = "moodindex-api_listmoods"
}

variable "create_mood_lambda" {
  default = "moodindex-api_createmood"
}

variable "login_lambda" {
  default = "moodindex-api_login"
}

variable "delete_user_lambda" {
  default = "moodindex-api_deleteuser"
}

variable "get_mood_lambda" {
  default = "moodindex-api_getmood"
}

variable "react_lambda" {
  default = "moodindex-api_reactmood"
}

variable "authorizer_lambda" {
  default = "moodindex-api_authorizer"
}

variable "integration_error_template" {
  default = <<EOF
  #set ($errorMessageObj = $util.parseJson($input.path('$.errorMessage'))) {
    "message" : "$errorMessageObj.message"
  }
EOF
}
