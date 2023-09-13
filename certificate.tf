resource "aws_acm_certificate" "cert" {
  provider          = aws.n-virginia
  domain_name       = var.domain_name
  validation_method = "DNS"
}
