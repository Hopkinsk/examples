#!/bin/bash -x

# set this to match your python file name
# for this example we're using lambda_function.py
LAMBDA_FUNCTION_NAME="lambda_function"
#
# adjust if desired, but not required
#
LAMBDA_EXECUTION_ROLE_NAME="lambda-s3-exec-role"
LAMBDA_EXECUTION_ACCESS_POLICY_NAME="lambda-s3-exec-policy"
###
LAMBDA_EXECUTION_ROLE_ARN=$(aws iam create-role \
  --role-name "$LAMBDA_EXECUTION_ROLE_NAME" \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }' \
  --query 'Role.Arn' \
  --output text
)

echo
echo LAMBDA_EXECUTION_ROLE_ARN=$LAMBDA_EXECUTION_ROLE_ARN
echo
sleep 5
aws iam put-role-policy \
  --role-name "$LAMBDA_EXECUTION_ROLE_NAME" \
  --policy-name "$LAMBDA_EXECUTION_ACCESS_POLICY_NAME" \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource": [
          "arn:aws:s3:::*"
        ]
      }
    ]
  }'

sleep 5
aws lambda create-function \
  --region us-west-2 \
  --function-name "${LAMBDA_FUNCTION_NAME}" \
  --zip-file "fileb://${LAMBDA_FUNCTION_NAME}.zip" \
  --role "$LAMBDA_EXECUTION_ROLE_ARN" \
  --handler "${LAMBDA_FUNCTION_NAME}.lambda_handler" \
  --runtime python3.6 \
  --timeout 300 \
  --memory-size 128
