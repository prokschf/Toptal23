
variable "bucket_name" {
  type        = string
  description = "The name of the bucket without the www. prefix. Normally domain_name."
}

resource "aws_s3_bucket" "www_bucket" {
  bucket = "${var.bucket_name}"
  acl    = "public-read"
  policy = templatefile("${path.module}/templates/s3-policy.json", { bucket = "${var.bucket_name}" })

  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.www_bucket.bucket

  index_document {
    suffix = "index.html"
  }


}
