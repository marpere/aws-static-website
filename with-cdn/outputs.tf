output "cloudfront_domain_name" {
  description = "Domain name from cloudfront distribution"
  value       = try(aws_cloudfront_distribution.s3_distribution.domain_name)
}