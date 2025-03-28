data "aws_iam_policy_document" "assume_role" {
  # Defines an assume role policy that allows AWS Lambda to assume this IAM role
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "rename" {
  # Creates an IAM role for the Lambda function with the assume role policy
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "rename" {
  # Creates an IAM policy that grants the Lambda function access to S3 and CloudWatch logs
  name = "lambda_s3_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        # Allows the Lambda function to read, write, and delete objects in the rename S3 bucket
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
        Resource = [
          aws_s3_bucket.rename.arn,       # Access to the bucket itself
          "${aws_s3_bucket.rename.arn}/*" # Access to objects inside the bucket
        ]
      },
      {
        # Grants permission to write logs to CloudWatch
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  # Attaches the IAM policy to the Lambda role
  role       = aws_iam_role.rename.name
  policy_arn = aws_iam_policy.rename.arn
}

resource "aws_lambda_permission" "allow_s3" {
  # Allows the S3 bucket to invoke the Lambda function
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rename.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.rename.arn
}