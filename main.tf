provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "/.aws/credentials"
  profile                 = "terraform"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_lambda_function" "greet_lambda" {
  filename      = "function.zip"
  function_name = "${var.lambda_function_name}"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "main.lambda_handler"
  source_code_hash = "${filebase64sha256("function.zip")}"
  depends_on    = ["aws_iam_role_policy_attachment.lambda_logs_and_vpc", "aws_cloudwatch_log_group.lambda_handler_logs"]

  runtime = "python3.6"

  environment {
    variables = {
      greeting = "Hi Atul Verma"
        DBPassword = "${var.DBPassword}"
        DBUsername = "${var.DBUsername}"
        Database = "${var.Database}"
        Server = "${var.Server}"
        Port = "${var.Port}"
    }
  }

  vpc_config {
       subnet_ids = "${var.lambda_subnet_ids}"
       security_group_ids = "${var.lambda_security_group_ids}"
   }
}


resource "aws_lambda_permission" "allow_cloudwatch_to_schedule_lambda" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.greet_lambda.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.every_thirty_minutes.arn}"
}

resource "aws_cloudwatch_log_group" "lambda_handler_logs" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 3
}

resource "aws_cloudwatch_event_target" "schedule_every_thirty_minutes" {
    rule = "${aws_cloudwatch_event_rule.every_thirty_minutes.name}"
    target_id = "greet_lambda"
    arn = "${aws_lambda_function.greet_lambda.arn}"
}

resource "aws_cloudwatch_event_rule" "every_thirty_minutes" {
    name = "every-thirty-minutes"
    description = "Fires every minute"
    schedule_expression = "rate(1 minute)"
}

resource "aws_iam_policy" "lambda_logging_and_vpc" {
  name = "lambda_logging"
  path = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Action": ["ec2:DescribeSecurityGroups",
                  "ec2:DescribeSubnets",
                  "ec2:DescribeVpcs",
                  "logs:CreateLogGroup",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents",
                  "ec2:CreateNetworkInterface",
                  "ec2:DescribeNetworkInterfaces",
                  "ec2:DeleteNetworkInterface"],
      "Resource": ["*"],
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs_and_vpc" {
  role = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_logging_and_vpc.arn}"
}
