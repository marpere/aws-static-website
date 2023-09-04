locals {
  mime_types = jsondecode(file("mime.json"))
  app_files = fileset(var.static_dir, "**")
  file_hashes = {
    for filename in local.app_files :
    filename => filemd5("${var.static_dir}${filename}")
  }
}

resource "aws_s3_bucket" "code" {
  bucket = var.app_name
}

resource "aws_s3_object" "code" {
  for_each     = local.app_files
  bucket       = aws_s3_bucket.code.id
  key          = each.key
  source       = "${var.static_dir}${each.key}"
  content_type = lookup(tomap(local.mime_types), element(split(".", each.key), length(split(".", each.key)) - 1))
  etag         = filemd5("${var.static_dir}${each.key}")
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
