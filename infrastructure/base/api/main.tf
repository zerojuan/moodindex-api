
resource "aws_api_gateway_rest_api" "moodindex-api" {
  name = "moodindex"
  description = "Mood Index ${var.environment_name} API"
}

resource "aws_api_gateway_deployment" "moodindex-api-deployment" {
  depends_on = [
    "aws_api_gateway_method.list-moods",
    "aws_api_gateway_method.create-mood",
    "aws_api_gateway_method.react-mood"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  stage_name  = "v1"
}

output "rest_api_url" {
  value = "${aws_api_gateway_deployment.moodindex-api-deployment.invoke_url}"
}

resource "aws_iam_role" "lambda" {
  name = "lambda-authorizer"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["apigateway.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach-lambda-auth-policy" {
    role       = "${aws_iam_role.lambda.name}"
    policy_arn = "arn:aws:iam::${var.account_id}:policy/LambdaAuthorizer"
}

resource "aws_api_gateway_authorizer" "moodindex-auth" {
  name = "moodindex-auth"
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  authorizer_uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${var.authorizer_lambda}:${var.alias}/invocations"
  authorizer_credentials = "${aws_iam_role.lambda.arn}"
}

// <ROOT>/moods
resource "aws_api_gateway_resource" "moods" {
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  parent_id = "${aws_api_gateway_rest_api.moodindex-api.root_resource_id}"
  path_part = "moods"
}

// <ROOT>/moods/{moodId}
resource "aws_api_gateway_resource" "mood-by-id" {
  depends_on = [ "aws_api_gateway_resource.moods" ]
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  parent_id = "${aws_api_gateway_resource.moods.id}"
  path_part = "{moodId}"
}

// TODO: <ROOT>/moods/{moodId}/reacts
resource "aws_api_gateway_resource" "MoodReacts" {
  depends_on = [ "aws_api_gateway_resource.moods" ]
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  parent_id = "${aws_api_gateway_resource.mood-by-id.id}"
  path_part = "reacts"
}

// <ROOT>/user
resource "aws_api_gateway_resource" "users" {
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  parent_id = "${aws_api_gateway_rest_api.moodindex-api.root_resource_id}"
  path_part="users"
}

// <ROOT>/user/{userId}
resource "aws_api_gateway_resource" "user-by-id" {
  rest_api_id = "${aws_api_gateway_rest_api.moodindex-api.id}"
  parent_id = "${aws_api_gateway_resource.users.id}"
  path_part = "{userId}"
}
