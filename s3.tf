locals {
  app_name  = "rdicidr"
  build_dir = "./build/"
  mime_types = {
    "css"  = "text/css"
    "html" = "text/html"
    "ico"  = "image/vnd.microsoft.icon"
    "js"   = "application/javascript"
    "json" = "application/json"
    "map"  = "application/json"
    "png"  = "image/png"
    "svg"  = "image/svg+xml"
    "txt"  = "text/plain"
  }
  app_files = fileset(local.build_dir, "**")
  file_hashes = {
    for filename in local.app_files :
    filename => filemd5("${local.build_dir}/${filename}")
  }
}

resource "aws_s3_bucket" "code" {
  bucket = "${local.app_name}-${terraform.workspace}"
}

resource "aws_s3_object" "code" {
  for_each     = local.app_files
  bucket       = aws_s3_bucket.code.id
  key          = each.value
  source       = "${local.build_dir}${each.value}"
  content_type = lookup(tomap(local.mime_types), element(split(".", each.key), length(split(".", each.key)) - 1))
  etag         = filemd5("${local.build_dir}${each.value}")
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.code.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront.json
}

data "aws_iam_policy_document" "allow_access_from_cloudfront" {
  statement {
    sid = "AllowCloudFrontServicePrincipalReadOnly"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.code.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}