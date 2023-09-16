locals {
  mime_types = jsondecode(file("mime_types_mapped_for_file_extensions.json"))
  app_files  = fileset(var.static_dir, "**")
  file_hashes = {
    for filename in local.app_files :
    filename => filemd5("${var.static_dir}${filename}")
  }
}

resource "aws_s3_bucket" "website" {
  bucket = var.domain_name
}

resource "aws_s3_bucket_website_configuration" "website" {  
  bucket = aws_s3_bucket.website.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "404.html"
  }
}

resource "aws_s3_object" "website" {
  for_each     = local.app_files
  bucket       = aws_s3_bucket.website.id
  key          = each.key
  source       = "${var.static_dir}${each.key}"
  content_type = lookup(tomap(local.mime_types), element(split(".", each.key), length(split(".", each.key)) - 1))
  etag         = filemd5("${var.static_dir}${each.key}")
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudflare" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudflare.json
}

data "aws_iam_policy_document" "allow_access_from_cloudflare" {
  statement {
    sid = "AllowCloudFlareIPs"
    principals {
      type        = "*"
      identifiers = ["AWS"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.website.arn}/*",
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = [
        "173.245.48.0/20",
        "103.21.244.0/22",
        "103.22.200.0/22",
        "103.31.4.0/22",
        "141.101.64.0/18",
        "108.162.192.0/18",
        "190.93.240.0/20",
        "188.114.96.0/20",
        "197.234.240.0/22",
        "198.41.128.0/17",
        "162.158.0.0/15",
        "104.16.0.0/13",
        "104.24.0.0/14",
        "172.64.0.0/13",
        "131.0.72.0/22"
      ]
    }
  }
}
