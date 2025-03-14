# Importing the AWS SDK for Python (boto3) to interact with AWS services.
# Also importing urllib.parse to decode URLs and ensure the object names are properly formatted.
import boto3
import urllib.parse

# Creating an S3 client using boto3 to interact with the S3 service.
s3 = boto3.client('s3')

# The main function that gets triggered whenever a new object is uploaded to the S3 bucket.
# 'event' contains details about the uploaded object, while 'context' provides runtime information about the Lambda function.
def lambda_handler(event, context):
    # Extracting the source bucket name (where the object was uploaded).
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    
    # Extracting the object key (name of the file uploaded to the bucket).
    # This value is URL-encoded, so we use urllib.parse.unquote_plus to decode it into a readable string.
    source_key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])
    
    # Defining the new name for the object. For this example, we are simply adding a "renamed-" prefix.
    new_key = f"renamed-{source_key}"
    
    try:
        # Copying the object to the same bucket but with the new name (new_key).
        # 'CopySource' specifies the bucket and key of the original object to be copied.
        copy_source = {'Bucket': source_bucket, 'Key': source_key}
        s3.copy_object(CopySource=copy_source, Bucket=source_bucket, Key=new_key)
        
        # Deleting the original object after copying it to the new name.
        s3.delete_object(Bucket=source_bucket, Key=source_key)
        
        # Logging a message to indicate the object was successfully renamed.
        print(f"Object renamed from {source_key} to {new_key}")
    except Exception as e:
        # If an error occurs during the process, log the error message.
        print(f"Error renaming object: {e}")
        # Raising the exception ensures the Lambda function reports the error back to AWS CloudWatch.
        raise e