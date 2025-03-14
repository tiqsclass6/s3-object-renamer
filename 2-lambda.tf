resource "aws_lambda_function" "rename" {
  function_name = "s3_rename_function"
  role          = aws_iam_role.rename.arn
  runtime       = "python3.11"
  handler       = "lambda_function.lambda_handler"
  filename      = "lambda_function_payload.zip" # This ZIP should include your Python code 


}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "./src/lambda_function.py"  # Ensure the filename matches the expected handler
  output_path = "lambda_function_payload.zip"
}




