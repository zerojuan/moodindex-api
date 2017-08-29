// GET <BASE>/moods
resource "aws_api_gateway_method" "ReactMood" {
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.MoodReacts.id}" 
  http_method = "POST"
  authorization = "CUSTOM"
  authorizer_id = "${aws_api_gateway_authorizer.moodindex-auth.id}"
  request_parameters = "${var.request_parameters}"
}

resource "aws_api_gateway_integration" "ReactMood-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.MoodReacts.id}"
  http_method = "GET"
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

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway-reactmood"
  action        = "lambda:InvokeFunction"
  function_name = "arn:aws:lambda:${var.region}:${var.account_id}:function:${var.react_lambda}:${var.alias}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.moodindex-api.id}/*/${aws_api_gateway_method.list-moods.http_method}/*"
}


resource "aws_api_gateway_integration_response" "ReactMood-integration-response200" {
  depends_on = [
    "aws_api_gateway_integration.ReactMood-integration",
    "aws_api_gateway_method_response.ReactMood-200-response" ]
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.moods.id}"
  http_method = "${aws_api_gateway_integration.ReactMood-integration.http_method}"
  status_code = "${aws_api_gateway_method_response.ReactMood-200-response.status_code}"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  response_templates = {
    "application/json" = <<EOF
    "$input.json('$')"
EOF
  }
}

resource "aws_api_gateway_method_response" "ReactMood-200-response" {
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.MoodReacts.id}"
  http_method = "${aws_api_gateway_method.ReactMood.http_method}"
  status_code = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}

resource "aws_api_gateway_integration_response" "ReactMood-integration-response200" {
  depends_on = [
    "aws_api_gateway_integration.ReactMood-integration",
    "aws_api_gateway_method_response.ReactMood-200-response"
   ]
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.MoodReacts.id}"
  http_method = "${aws_api_gateway_integration.ReactMood-integration.http_method}"
  status_code = "${aws_api_gateway_method_response.ReactMood-200-response.status_code}"
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

resource "aws_api_gateway_method_response" "ReactMood-400-response" {
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.MoodReacts.id}"
  http_method = "${aws_api_gateway_integration.ReactMood-integration.http_method}"
  status_code = "400"
  response_models = { "application/json" = "Error" }
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}

resource "aws_api_gateway_integration_response" "ReactMood-integration-response400" {
  depends_on = [
    "aws_api_gateway_integration.ReactMood-integration",
    "aws_api_gateway_method_response.ReactMood-400-response"
   ]
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.MoodReacts.id}"
  http_method = "${aws_api_gateway_integration.ReactMood-integration.http_method}"
  status_code = "${aws_api_gateway_method_response.ReactMood-400-response.status_code}"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  selection_pattern = ".*\"NotFound\".*"

  response_templates = {
    "application/json" = "${var.integration_error_template}"
  }
}