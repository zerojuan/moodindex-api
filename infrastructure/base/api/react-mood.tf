// GET <BASE>/moods
resource "aws_api_gateway_method" "CreateReact" {
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  resource_id = "${aws_api_gateway_resource.MoodReacts.id}" 
  http_method = "POST"
  authorization = "CUSTOM"
  authorizer_id = "${aws_api_gateway_authorizer.MoodIndexAuth.id}"
  request_parameters = "${var.request_parameters}"
}

resource "aws_api_gateway_integration" "CreateReactIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  resource_id = "${aws_api_gateway_resource.MoodReacts.id}"
  http_method = "POST"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${var.react_lambda}:${var.alias}/invocations"
  integration_http_method = "POST" // lambda integration can only be POST
  request_templates = {
    "application/json" = <<EOF
    {
      "principalId": "$context.authorizer.principalId",
      "mood": $input.json('$')
    }
EOF
  }
}

resource "aws_lambda_permission" "APIGW_LAMBDA_CREATEREACT" {
  statement_id  = "AllowExecutionFromAPIGateway-createreact"
  action        = "lambda:InvokeFunction"
  function_name = "arn:aws:lambda:${var.region}:${var.account_id}:function:${var.react_lambda}:${var.alias}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.MoodIndexAPI.id}/*/${aws_api_gateway_method.CreateReact.http_method}/*"
}

resource "aws_api_gateway_method_response" "CreateReactMethodResponse200" {
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  resource_id = "${aws_api_gateway_resource.MoodReacts.id}"
  http_method = "${aws_api_gateway_method.CreateReact.http_method}"
  status_code = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}

resource "aws_api_gateway_integration_response" "CreateReactIntegrationResponse200" {
  depends_on = [
    "aws_api_gateway_integration.CreateReactIntegration",
    "aws_api_gateway_method_response.CreateReactMethodResponse200"
   ]
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  resource_id = "${aws_api_gateway_resource.MoodReacts.id}"
  http_method = "${aws_api_gateway_integration.CreateReactIntegration.http_method}"
  status_code = "${aws_api_gateway_method_response.CreateReactMethodResponse200.status_code}"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  response_templates = {
    "application/json" = <<EOF
    {
      "body": $input.json('$')
    }
EOF
  }
}

resource "aws_api_gateway_method_response" "CreateReactMethodResponse400" {
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  resource_id = "${aws_api_gateway_resource.MoodReacts.id}"
  http_method = "${aws_api_gateway_integration.CreateReactIntegration.http_method}"
  status_code = "400"
  response_models = { "application/json" = "Error" }
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}

resource "aws_api_gateway_integration_response" "CreateReactIntegrationResponse400" {
  depends_on = [
    "aws_api_gateway_integration.CreateReactIntegration",
    "aws_api_gateway_method_response.CreateReactMethodResponse400"
   ]
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  resource_id = "${aws_api_gateway_resource.MoodReacts.id}"
  http_method = "${aws_api_gateway_integration.CreateReactIntegration.http_method}"
  status_code = "${aws_api_gateway_method_response.CreateReactMethodResponse400.status_code}"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  selection_pattern = ".*\"BadRequest\".*"

  response_templates = {
    "application/json" = "${var.integration_error_template}"
  }
}

resource "aws_api_gateway_method_response" "CreateReactMethodResponse404" {
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  resource_id = "${aws_api_gateway_resource.MoodReacts.id}"
  http_method = "${aws_api_gateway_integration.CreateReactIntegration.http_method}"
  status_code = "404"
  response_models = { "application/json" = "Error" }
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}

resource "aws_api_gateway_integration_response" "CreateReactIntegrationResponse404" {
  depends_on = [
    "aws_api_gateway_integration.CreateReactIntegration",
    "aws_api_gateway_method_response.CreateReactMethodResponse404"
   ]
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  resource_id = "${aws_api_gateway_resource.MoodReacts.id}"
  http_method = "${aws_api_gateway_integration.CreateReactIntegration.http_method}"
  status_code = "${aws_api_gateway_method_response.CreateReactMethodResponse404.status_code}"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  selection_pattern = ".*\"NotFound\".*"

  response_templates = {
    "application/json" = "${var.integration_error_template}"
  }
}