# MoodIndex Api
[![CircleCI](https://circleci.com/gh/zerojuan/moodindex-api.svg?style=svg)](https://circleci.com/gh/zerojuan/moodindex-api)
Record your mood for the day.

## Note:
test password is `test1`

## Setup Resources
1. cd /infra/dev
2. terraform plan
3. terraform apply

## Setup Lambda Functions
1. apex deploy

## How to Run Tests Locally
1. Download and install dynamodb local. (Tested on v1.11.86) http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html
2. Run dynamobdb local using default settings
`java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar`
3. Create db tables
`./bin/local-setup`
4. Populate default data
`./bin/db`
5. Run tests
`npm run test`