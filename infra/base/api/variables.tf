variable "integration_error_template" {
  default = <<EOF
  #set ($errorMessageObj = $util.parseJson($input.path('$.errorMessage')) {
    "message" : "$errorMessageObj.message"
  }
EOF
}
