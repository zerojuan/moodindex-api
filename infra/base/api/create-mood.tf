// POST <BASE>/moods
resource "aws_api_gateway_method" "create-mood" {
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.moods.id}"
  http_method = "POST"
  authorization = "CUSTOM"
  authorizer_id = "${aws_api_gateway_authorizer.moodindex-auth.id}"
  request_parameters = "${var.request_parameters}"
  # request_models = { "application/json" = "${var.request_model}" }
}

resource "aws_api_gateway_integration" "create-mood-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.moods.id}"
  http_method = "POST"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${var.create_mood_lambda}:${var.alias}/invocations"
  integration_http_method = "POST"
  request_templates = {
    "application/json" = <<EOF
    {
      "body": $input.json($)
    }
EOF
  }
}

resource "aws_api_gateway_integration_response" "create-mood-integration-response200" {
  depends_on = [ "aws_api_gateway_integration.create-mood-integration" ]
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.moods.id}"
  http_method = "${aws_api_gateway_integration.create-mood-integration.http_method}"
  status_code = "${aws_api_gateway_method_response.create-mood-200-response.status_code}"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  response_templates = {
    "application/json" = <<EOF
    {
      "principalId": $context.authorizer.principalId,
      "body": $input.json($)
    }
EOF
  }
}

resource "aws_api_gateway_integration_response" "create-mood-integration-response400" {
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.moods.id}"
  http_method = "${aws_api_gateway_integration.create-mood-integration.http_method}"
  status_code = "${aws_api_gateway_method_response.create-mood-400-response.status_code}"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  selection_pattern = ".*\"NotFound\".*"

  response_templates = {
    "application/json" = "${var.integration_error_template}"
  }
}

resource "aws_api_gateway_method_response" "create-mood-200-response" {
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.moods.id}"
  http_method = "${aws_api_gateway_integration.create-mood-integration.http_method}"
  status_code = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}

resource "aws_api_gateway_method_response" "create-mood-400-response" {
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.moods.id}"
  http_method = "${aws_api_gateway_integration.create-mood-integration.http_method}"
  status_code = "400"
  response_models = { "application/json" = "Error" }
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}
