resource "aws_api_gateway_model" "Mood" {
  rest_api_id  = "${aws_api_gateway_rest_api.moodindex-api.id}"
  name         = "Mood"
  description  = "JSON schema of a Mood"
  content_type = "application/json"

  schema = <<EOF
{
  "who": "object",
  "what": "object",
  "when": "date",
  "why": "string"
}
EOF
}
