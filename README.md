# S3 Rename Function with AWS Lambda and Terraform

## Overview

This project sets up an AWS Lambda function to automatically rename files uploaded to an S3 bucket. The Lambda function is triggered by S3 events and renames files by prepending "rename-" to the new object's key. This serves as a straightforward POC project.

## Architecture

### Architecture Diagram
![Diagram](assets/s3-renamer-v2.svg)

### Architecture Overview

- **Lambda Function:** Deployed as `s3_rename_function`, listens for S3 events, renames files by adding "renamed-" prefix, and deletes the original file.
- **S3 Bucket:** Created with a prefix (e.g., "rename-test-"); stores files to be renamed.
- **S3 Event Notification:** Configured on the S3 bucket to trigger the Lambda function when a new object is created.
- **IAM Roles and Policies:** An IAM role is assumed by the Lambda function with an attached policy that grants permissions to interact with S3 and write logs to CloudWatch.




## Tools

- **Terraform**: Used for infrastructure as code (IaC) deployment.
- **Python**: Used to write the Lambda function
- **Boto3**: The AWS Python SDK and client library to wrap API calls
- **AWS CLI Utility**: Used for quicker interactions and streamlining workflow

## Quick Start: ClickOps Guide

### 1. Open the AWS Console
Open tabs for the S3, Lambda, and IAM dashboards

### 2. Setup IAM Role
- The Lambda needs permissons to access cloud watch logs and to be able to access S3. 
- Lambda does not really have an identity, as such, it will assume (using the STS) a role we create. 

1) Open the IAM dashboard
2) Go to Roles, create a new role
3) Leave default selection for "Trusted entity type", which is "AWS Service" (given that Lambda will use this role and is a service)
4) "Use Case" is set to "Lambda" then click next
5) Choose the following two policies: "AWSLambdaBasicExecutionRole"; "AmazonS3FullAccess"
6) Click next, then name the role, then review selection and click "Create Role" 

### 3. Create Lambda 
- Go [here](src/lambda_function.py) and copy the code.

1) Open the Lambda dashboard and choose "Create a function"
2) Name the function and choose a new python runtime (like 3.11)
3) Go to "Change default execution role"
    - Go to "Use an existing role"
    - Under the "Existing Role" drop down menu, select the role you made in step 2
4) Click on "Create Function"
5) Scroll down a bit, then paste the python code in the code editor and click on the deploy button

### 4. Create S3 Bucket
1) Go to the S3 dashboard 
2) Create a bucket with default settings
3) Open the bucket you created and go to the "Properties" tab
4) Go the "Event notifications" section 
    - Select "create event notification"
    - Name the notification (ex. "on upload")
    - In Event Type section, select "s3:ObjectCreated:Put" under the object creation section
    - In the Destination section go to "Choose your Lambda function" and use the drop down menu and choose your function
    - Go to save changes

### 5. Test project by uploading an object to the new bucket

## Terraform Deploymen Instructions

### 1. Move to your projects folder
Move into your projects folder inside the TheoWAF directory on your computer for example. 

### 2. Clone the Repository


```sh
git clone https://github.com/aaron-dm-mcdonald/s3-object-renamer.git lambda-rename-s3
cd lambda-rename-s3
```

### 3. Initialize and Apply Terraform

```sh
terraform init
terraform apply -auto-approve
```

### 4. Get the Bucket Name

Note the bucket name during terraform runtime or execute:

```sh
terraform output s3_bucket_name
```

### 5. Upload a File (Triggering Lambda)

```sh
aws s3 cp <LOCAL-FILE-PATH> s3://<YOUR-BUCKET-NAME>/<YOUR-FILE-KEY>
```

### 6. List Files in Bucket

```sh
aws s3 ls s3://<YOUR-BUCKET-NAME>/
```

## Testing Lambda Manually

To test without an actual S3 event, use AWS CLI:

1) Edit the ```tests/event.json``` file with current info. This is a JSON formatted file:

2) Use jq to verify formatting (optional):
```jq . tests/event.json```

3) Use the aws CLI to invoke the lambda while passing in the JSON payload to simulate an S3 upload trigger:
```sh
aws lambda invoke --function-name s3_rename_function \
  --payload file://tests/event.json tests/response.json \
  --cli-binary-format raw-in-base64-out >> tests/output.txt
```


4) 
    - Run ```cat tests/response.json``` to view contents. Expected results are "null"
    - Run ```cat tests/output.txt``` to view output of the command. Expected results are a HTTP status code of 200.
   


## Notes

- Ensure that your IAM role allows S3 read/write access for Lambda.
- The Lambda function runs in response to S3 events, so any file upload matching the event filter will trigger it.

## Lambda Function Code Breakdown

This Lambda function listens for new file uploads to an S3 bucket and renames them by adding a **"renamed-"** prefix.

### **Key Steps in the Code**
1. **Imports AWS SDK (boto3) and urllib.parse** – Used for interacting with S3 and decoding filenames.
2. **Extracts the bucket name and file name** from the event payload.
3. **Creates a new file name** by adding the `"renamed-"` prefix.
4. **Copies the original file to the new name** in the same bucket.
5. **Deletes the original file** after copying.

### **Lambda Code**
[The Lambda Function Source Code](src/lambda_function.py)




