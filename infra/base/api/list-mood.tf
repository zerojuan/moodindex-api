// GET <BASE>/moods
resource "aws_api_gateway_method" "list-moods" {
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.moods.id}"
  http_method = "GET"
  authorization = "CUSTOM"
  authorizer_id = "${aws_api_gateway_authorizer.moodindex-auth.id}"
  request_parameters = "${var.request_parameters}"
}

resource "aws_api_gateway_integration" "list-moods-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.moods.id}"
  http_method = "GET"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${var.list_mood_lambda}:${var.alias}/invocations"
  integration_http_method = "GET"
  request_templates = {
    "application/json" = <<EOF
    {
      "principalId": $context.authorizer.principalId,
      "queryParams": {
        "pageSize": $input.params('pageSize'),
        "currentIndex": {
          "ownerId": $input.params('ownerId'),
          "created": $input.params('created')
        }
      }
    }
EOF
  }
}

resource "aws_api_gateway_integration_response" "list-moods-integration-response200" {
  depends_on = [ "aws_api_gateway_integration.list-moods-integration" ]
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.moods.id}"
  http_method = "${aws_api_gateway_integration.list-moods-integration.http_method}"
  status_code = "${aws_api_gateway_method_response.list-moods-200-response.status_code}"
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

resource "aws_api_gateway_integration_response" "list-moods-integration-response400" {
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.moods.id}"
  http_method = "${aws_api_gateway_integration.list-moods-integration.http_method}"
  status_code = "${aws_api_gateway_method_response.list-moods-400-response.status_code}"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  selection_pattern = ".*\"NotFound\".*"

  response_templates = {
    "application/json" = "${var.integration_error_template}"
  }
}

resource "aws_api_gateway_method_response" "list-moods-200-response" {
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.moods.id}"
  http_method = "${aws_api_gateway_method.list-moods.http_method}"
  status_code = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}

resource "aws_api_gateway_method_response" "list-moods-400-response" {
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  resource_id = "${aws_api_gateway_resource.moods.id}"
  http_method = "${aws_api_gateway_method.list-moods.http_method}"
  status_code = "400"
  response_models = { "application/json" = "Error" }
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}
