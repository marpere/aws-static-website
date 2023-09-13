resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.code.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = aws_s3_bucket.code.id
  }

  aliases = [var.domain_name]

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = var.app_name

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.code.id

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

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
  }
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = var.app_name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "null_resource" "invalidate_cache" {
  triggers = local.file_hashes

  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id=${aws_cloudfront_distribution.s3_distribution.id} --paths=/*"
  }
}
