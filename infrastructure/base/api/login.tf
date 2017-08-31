// POST <base>/login
resource "aws_api_gateway_method" "Login" {
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  resource_id = "${aws_api_gateway_resource.Login.id}"
  http_method = "POST"
  authorization = "NONE"
  request_parameters = "${var.request_parameters}"
}

resource "aws_api_gateway_integration" "LoginIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  resource_id = "${aws_api_gateway_resource.Login.id}"
  http_method = "POST"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${var.login_lambda}:${var.alias}/invocations"
  integration_http_method = "POST" // lambda integration can only be POST
  request_templates = {
    "application/json" = <<EOF
    {
      "user": $input.json('$')
    }
EOF
  }
}

resource "aws_lambda_permission" "APIGW_LAMBDA_LOGIN" {
  statement_id  = "AllowExecutionFromAPIGateway-login"
  action        = "lambda:InvokeFunction"
  function_name = "arn:aws:lambda:${var.region}:${var.account_id}:function:${var.login_lambda}:${var.alias}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.MoodIndexAPI.id}/*/${aws_api_gateway_method.Login.http_method}/*"
}

resource "aws_api_gateway_method_response" "LoginMethodResponse200" {
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  resource_id = "${aws_api_gateway_resource.Login.id}"
  http_method = "${aws_api_gateway_integration.LoginIntegration.http_method}"
  status_code = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}


resource "aws_api_gateway_integration_response" "LoginIntegrationResponse200" {
  depends_on = [
    "aws_api_gateway_integration.LoginIntegration",
    "aws_api_gateway_method_response.LoginMethodResponse200"
   ]
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  resource_id = "${aws_api_gateway_resource.Login.id}"
  http_method = "${aws_api_gateway_integration.LoginIntegration.http_method}"
  status_code = "${aws_api_gateway_method_response.LoginMethodResponse200.status_code}"
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

resource "aws_api_gateway_method_response" "LoginMethodResponse400" {
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  resource_id = "${aws_api_gateway_resource.Login.id}"
  http_method = "${aws_api_gateway_integration.LoginItegration.http_method}"
  status_code = "400"
  response_models = { "application/json" = "Error" }
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}

resource "aws_api_gateway_integration_response" "LoginIntegrationResponse400" {
  depends_on = [
    "aws_api_gateway_integration.LoginIntegration",
    "aws_api_gateway_method_response.LoginMethodResponse400"
   ]
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  resource_id = "${aws_api_gateway_resource.Login.id}"
  http_method = "${aws_api_gateway_integration.LoginIntegration.http_method}"
  status_code = "${aws_api_gateway_method_response.LoginMethodResponse400.status_code}"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  selection_pattern = ".*\"NotFound\".*"

  response_templates = {
    "application/json" = "${var.integration_error_template}"
  }
}
