
resource "aws_api_gateway_rest_api" "MoodIndexAPI" {
  name = "moodindex"
  description = "Mood Index ${var.environment_name} API"
}

resource "aws_api_gateway_deployment" "MoodIndexDeployment" {
  depends_on = [
    "aws_api_gateway_method.ListMoods",
    "aws_api_gateway_method.CreateMood",
    "aws_api_gateway_method.CreateReact",
    "aws_api_gateway_method.Login"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  stage_name  = "v1"
  description = "${var.deployment_description}"
}

output "rest_api_url" {
  value = "${aws_api_gateway_deployment.MoodIndexDeployment.invoke_url}"
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

resource "aws_api_gateway_authorizer" "MoodIndexAuth" {
  name = "moodindex-auth"
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  authorizer_uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${var.authorizer_lambda}:${var.alias}/invocations"
  authorizer_credentials = "${aws_iam_role.lambda.arn}"
}

resource "aws_api_gateway_resource" "Login" {
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  parent_id = "${aws_api_gateway_rest_api.MoodIndexAPI.root_resource_id}"
  path_part = "login"
}

// <ROOT>/moods
resource "aws_api_gateway_resource" "Moods" {
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  parent_id = "${aws_api_gateway_rest_api.MoodIndexAPI.root_resource_id}"
  path_part = "moods"
}

// <ROOT>/moods/{moodId}
resource "aws_api_gateway_resource" "MoodById" {
  depends_on = [ "aws_api_gateway_resource.Moods" ]
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  parent_id = "${aws_api_gateway_resource.Moods.id}"
  path_part = "{moodId}"
}

// TODO: <ROOT>/moods/{moodId}/reacts
resource "aws_api_gateway_resource" "MoodReacts" {
  depends_on = [ "aws_api_gateway_resource.Moods" ]
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  parent_id = "${aws_api_gateway_resource.MoodById.id}"
  path_part = "reacts"
}

// <ROOT>/user
resource "aws_api_gateway_resource" "Users" {
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  parent_id = "${aws_api_gateway_rest_api.MoodIndexAPI.root_resource_id}"
  path_part="users"
}

// <ROOT>/user/{userId}
resource "aws_api_gateway_resource" "UserById" {
  rest_api_id = "${aws_api_gateway_rest_api.MoodIndexAPI.id}"
  parent_id = "${aws_api_gateway_resource.Users.id}"
  path_part = "{userId}"
}
