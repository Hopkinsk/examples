# Snowflake S3 Lambda Loader

## Creating a Python Deployment Package

### Create the Lambda Execution Environment
In order to run our Python S3 Lambda Loader for Snowflake we need to first create a deployment package containing our code and its dependancies. An easy way to do this is to grab a `t2.micro` instance and set up an execution environment that mimics the one the Python Lambda will run in. For more details on this you can see the [AWS Lambda Developer Guide](http://docs.aws.amazon.com/lambda/latest/dg/current-supported-versions.html). To request an EC2 instance, you can use the [AWS CLI ](https://aws.amazon.com/cli/), which can be installed using the following command:
```
pip install awscli
```
Now we can use the `aws` command to create an EC2 instance:
```
aws ec2 run-instances \
  --image-id ami-e7527ed7 \
  --count 1 \
  --instance-type t2.micro \
  --key-name <your-ssh-key-name> \
  --associate-public-ip-address
```

Now that we have our `t2.micro` instance, ssh to it using:
```
ssh -i /path/to/your/ssh-key/key-name.pem -l ec2-user <ip address or hostname>
```
Once we are successfully connected to our `t2.micro` instance, run the following two commands:
```
sudo yum -y update
sudo yum -y install gcc libffi-devel openssl-devel
```
This will update packages and install the required dependancies for the Snowflake Connector for Python.

### Create the Python Deployment Package

#### Edit the Lambda Handler Function

You can see `lambda_function.py` for a basic Lambda handler function that uses the Snowflake Connector for Python.  Adjust the connection variables, table name, and S3 bucket/path to match your environment.

#### Create and Package the Python Virtual Environment

The script `package-lambda-function.sh` contains the commands that will create and package up the Python environment for our Lambda function.  Note: if you change the name of the file containing the Lambda handler, you will also have to modify this script.

After running this script, the file `lambda_function.zip` contains our Python Lambda handler code/file as well as the Python dependancies needed to run in the AWS Lambda environment.

### Create and Configure the AWS Lambda Permissions

In order for us to execute the Lambda, we need to use the `aws` command to create and set the appropriate permissions for the roles and policies and then upload the zip archive containing our Python environment. These commands can be found in the file `aws-lambda-setup.sh`.

At this point we can then test fire the Lambda and see the output in the AWS Web Console UI.  Navigate to **Lambda** > **Functions** > **lambda_function**.  You should now see the blue **Test** button in the upper left. If you click this, it will fire the Lambda.

Once we know the Lambda runs successfully, we can then use the AWS Console UI to configure the Lambda to run at some recurring time interval. From the **Event sources** tab, click **Add event source**. From the drop down menu select **Scheduled Event**. Fill in the **Name** and **Description** as you see fit and select an time interval from the **Schedule expression**. For example, you can select **rate(5 minutes)** to trigger the Lambda every 5 minutes.  Click **Submit** to add the event source.

### Updating the Lambda Handler

If you wish to make code changes, you can repackage up the zip archive and use this command to simply upload the new code for your function:
```
aws lambda update-function-code \
  --function-name lambda_function \
  --zip-file fileb://lambda_function.zip
```

### Commands to Remove the Lambda Function

If you want to remove the function, role, and policy, you can use these three commands to do so.
```
aws iam delete-role-policy --role-name lambda-s3-exec-role --policy-name lambda-s3-exec-policy
aws iam delete-role --role-name lambda-s3-exec-role
aws lambda delete-function --function-name lambda_function
```
