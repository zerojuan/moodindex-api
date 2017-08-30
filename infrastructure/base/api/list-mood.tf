// GET <BASE>/moods
resource "aws_api_gateway_method" "ListMoods" {
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  resource_id = "${aws_api_gateway_resource.Moods.id}"
  http_method = "GET"
  authorization = "NONE"
  request_parameters = {
    "method.request.header.Authorization" = true,
    "method.request.querystring.pageSize" = true,
    "method.request.querystring.ownerId" = true,
    "method.request.querystring.created" = true
  }
}

resource "aws_api_gateway_integration" "ListMoodsIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  resource_id = "${aws_api_gateway_resource.Moods.id}"
  http_method = "GET"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${var.list_mood_lambda}:${var.alias}/invocations"
  integration_http_method = "POST" // lambda integration can only be POST
  request_templates = {
    "application/json" = <<EOF
    {
      "queryParams": {
        "pageSize": "$input.params('pageSize')",
        "currentIndex": {
          "ownerId": "$input.params('ownerId')",
          "created": "$input.params('created')"
        }
      }
    }
EOF
  }
}

resource "aws_lambda_permission" "APIGW_LAMBDA_LISTMOODS" {
  statement_id  = "AllowExecutionFromAPIGateway-listmood"
  action        = "lambda:InvokeFunction"
  function_name = "arn:aws:lambda:${var.region}:${var.account_id}:function:${var.list_mood_lambda}:${var.alias}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.moodindex-api.id}/*/${aws_api_gateway_method.ListMoods.http_method}/*"
}


resource "aws_api_gateway_integration_response" "ListMoodsIntegrationResponse200" {
  depends_on = [
    "aws_api_gateway_integration.ListMoodsIntegration",
    "aws_api_gateway_method_response.ListMoodsMethodResponse200" ]
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  resource_id = "${aws_api_gateway_resource.Moods.id}"
  http_method = "${aws_api_gateway_integration.ListMoodsIntegration.http_method}"
  status_code = "${aws_api_gateway_method_response.ListMoodsMethodResponse200.status_code}"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  response_templates = {
    "application/json" = <<EOF
    "$input.json('$')"
EOF
  }
}

resource "aws_api_gateway_method_response" "ListMoodsMethodResponse200" {
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  resource_id = "${aws_api_gateway_resource.Moods.id}"
  http_method = "${aws_api_gateway_method.ListMoods.http_method}"
  status_code = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}

resource "aws_api_gateway_integration_response" "ListMoodsIntegrationResponse400" {
  depends_on = [
    "aws_api_gateway_integration.ListMoodsIntegration",
    "aws_api_gateway_method_response.ListMoodsMethodResponse400" ]
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  resource_id = "${aws_api_gateway_resource.Moods.id}"
  http_method = "${aws_api_gateway_integration.ListMoodsIntegration.http_method}"
  status_code = "${aws_api_gateway_method_response.ListMoodsMethodResponse400.status_code}"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  selection_pattern = ".*\"NotFound\".*"

  response_templates = {
    "application/json" = "${var.integration_error_template}"
  }
}

resource "aws_api_gateway_method_response" "ListMoodsMethodResponse400" {
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  resource_id = "${aws_api_gateway_resource.Moods.id}"
  http_method = "${aws_api_gateway_method.ListMoods.http_method}"
  status_code = "400"
  response_models = { "application/json" = "Error" }
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}
