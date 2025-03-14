resource "aws_s3_bucket" "rename" {
  bucket_prefix = "rename-test-" # Change this to your desired bucket name
  force_destroy = true

}

resource "aws_s3_bucket_notification" "rename_notification" {
  bucket = aws_s3_bucket.rename.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.rename.arn
    events              = ["s3:ObjectCreated:Put"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}




############# Test file before lambda
# Create a local file before uploading it to S3
resource "local_file" "generated_file" {
  filename = "tests/test-file.txt"
  content  = "This file is created by Terraform and uploaded to S3 before Lambda deployment."
}

# Upload the generated file to S3
resource "aws_s3_object" "initial_file" {
  bucket = aws_s3_bucket.rename.id
  key    = "initial-test-file.txt"
  source = local_file.generated_file.filename
  depends_on = [local_file.generated_file] # Ensure file is created before upload
}


