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