# file: lambda_function.py

import snowflake.connector

# NOTE: the function name here has to match the aws commands we create
# the AWS Lambda
def lambda_handler(event, context):
  print("Event: %s" % event)
  # adjust these for your environment
  ctx = snowflake.connector.connect(
    host='<account>.snowflakecomputing.com',
    account='<account>',
    user='<username>',
    password=' password>',
    database='<db>',
    schema='public',
    warehouse='<warehouse>',
    timezone='UTC',
  )
  # this example copies into a table from a user owned s3 bucket
  sql = """copy into <table> from 's3://<your-s3-bucket-to-load-from>/'
         credentials=(aws_key_id='<your-aws-key>' aws_secret_key='<your-aws-secret-key>')
         file_format=(type=json)"""
  cur = ctx.cursor()
  cur.execute(sql)
  # little python to return the result set as a JSON document
  rs = [dict((cur.description[i][0], value) for i, value in enumerate(row)) for row in cur.fetchall()]
  cur.close()
  ctx.close()
  print(rs)
  return(rs)
