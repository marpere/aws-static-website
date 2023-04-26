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
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_s3_bucket" "code_prod" {
  bucket = "${local.app_name}-prod"
}

resource "aws_s3_bucket" "code_devel" {
  bucket = "${local.app_name}-devel"
}

resource "aws_s3_bucket" "code_stage" {
  bucket = "${local.app_name}-stage"
}

data "aws_s3_bucket" "code" {
  bucket = "${local.app_name}-${var.env}"
  depends_on = [
    aws_s3_bucket.code_prod,
    aws_s3_bucket.code_devel,
    aws_s3_bucket.code_stage
  ]
}

resource "aws_s3_object" "code" {
  for_each     = fileset(local.build_dir, "**")
  bucket       = data.aws_s3_bucket.code.id
  key          = each.value
  source       = "${local.build_dir}${each.value}"
  content_type = lookup(tomap(local.mime_types), element(split(".", each.key), length(split(".", each.key)) - 1))
  etag         = filemd5("${local.build_dir}${each.value}")
}


# PRODUCTION


resource "aws_s3_bucket_policy" "allow_access_from_cloudfront_prod" {
  bucket = aws_s3_bucket.code_prod.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront_prod.json
}

data "aws_iam_policy_document" "allow_access_from_cloudfront_prod" {
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
      "${aws_s3_bucket.code_prod.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution_prod.arn]
    }
  }
}

resource "aws_cloudfront_distribution" "s3_distribution_prod" {
  origin {
    domain_name              = aws_s3_bucket.code_prod.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.prod.id
    origin_id                = aws_s3_bucket.code_prod.id
  }

  comment             = "Production"
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.code_prod.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "Production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_origin_access_control" "prod" {
  name                              = "prod"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}



# DEVELOPMENT



resource "aws_s3_bucket_policy" "allow_access_from_cloudfront_devel" {
  bucket = aws_s3_bucket.code_devel.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront_devel.json
}

data "aws_iam_policy_document" "allow_access_from_cloudfront_devel" {
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
      "${aws_s3_bucket.code_devel.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution_devel.arn]
    }
  }
}

resource "aws_cloudfront_distribution" "s3_distribution_devel" {
  origin {
    domain_name              = aws_s3_bucket.code_devel.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.devel.id
    origin_id                = aws_s3_bucket.code_devel.id
  }

  comment             = "Development"
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.code_devel.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "Development"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_origin_access_control" "devel" {
  name                              = "devel"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}




# STAGE



resource "aws_s3_bucket_policy" "allow_access_from_cloudfront_stage" {
  bucket = aws_s3_bucket.code_stage.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront_stage.json
}

data "aws_iam_policy_document" "allow_access_from_cloudfront_stage" {
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
      "${aws_s3_bucket.code_stage.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution_stage.arn]
    }
  }
}

resource "aws_cloudfront_distribution" "s3_distribution_stage" {
  origin {
    domain_name              = aws_s3_bucket.code_stage.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.stage.id
    origin_id                = aws_s3_bucket.code_stage.id
  }

  comment             = "Stage"
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.code_stage.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "Stage"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_origin_access_control" "stage" {
  name                              = "stage"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}