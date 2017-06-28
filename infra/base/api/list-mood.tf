variable "list-mood-lambda" {
  default = "list-mood"
}

// GET <BASE>/moods
resource "aws_api_gateway_method" "get-mood" {
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.moods.id}"
  http_method = "GET"
  authorization = "NONE"
  request_parameters = "${var.request_parameters}"
  request_models = { "application/json" = "${var.request_model}" }
}

resource "aws_api_gateway_integration" "get-mood-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.moods.id}"
  http_method = "GET"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${var.list-mood-lambda}/invocations"
  integration_http_method = "GET"
  request_templates = {
    "application/json" = <<EOF
    {
      "body": $input.json($)
    }
EOF
  }
}

resource "aws_api_gateway_integration_response" "get-mood-integration-response200" {
  depends_on = [ "aws_api_gateway_integration.get-mood-integration" ]
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.moods.id}"
  http_method = "${aws_api_gateway_method.get-mood-integration.http_method}"
  status_code = "${aws_api_gateway_method_response.get-mood-200-response.status_code}"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  response_templates = {
    "application/json" = <<EOF
    {
      "body": $input.json($)
    }
EOF
  }
}

resource "aws_api_gateway_integration_response" "get-mood-integration-response400" {
  depends_on = [ "aws_api_gateway_integration.get-mood-integration" ]
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.moods.id}"
  http_method = "${aws_api_gateway_method.get-mood-integration.http_method}"
  status_code = "${aws_api_gateway_method_response.get-mood-400-response.status_code}"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  selection_pattern = ".*\"NotFound\".*"

  response_templates = {
    "application/json" = "${var.integration_error_template}"
  }
}

resource "aws_api_gateway_method_response" "get-mood-200-response" {
  depends_on = [ "aws_api_gateway_integration.ResourceMethodIntegration" ]
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.moods.id}"
  http_method = "${aws_api_gateway_method.get-mood.http_method}"
  status_code = "200"
  response_models = { "application/json" = "${aws_api_gateway_model.Mood}" }
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}

resource "aws_api_gateway_method_response" "get-mood-400-response" {
  depends_on = [ "aws_api_gateway_integration.ResourceMethodIntegration" ]
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.moods.id}"
  http_method = "${aws_api_gateway_method.get-mood.http_method}"
  status_code = "400"
  response_models = { "application/json" = "Error" }
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}
