module "aws_reverse_proxy" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_reverse_proxy#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v12.0...master
  source    = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_reverse_proxy?ref=v12.0"
  providers = { aws.us_east_1 = aws.us_east_1 } # this alias is needed because ACM is only available in the "us-east-1" region

  # S3 website endpoints are only available over plain HTTP
  origin_url = "http://${aws_s3_bucket.this.website_endpoint}/"

  # Somewhat perplexingly, this is the "correct" way to ensure users can't bypass CloudFront on their way to S3 resources
  # https://abridge2devnull.com/posts/2018/01/restricting-access-to-a-cloudfront-s3-website-origin/
  origin_custom_header_name  = "User-Agent"
  origin_custom_header_value = random_string.s3_read_password.result

  site_domain            = var.site_domain
  name_prefix            = "${local.name_prefix}-rp"
  comment_prefix         = var.comment_prefix
  cloudfront_price_class = var.cloudfront_price_class
  viewer_https_only      = var.viewer_https_only
  cache_ttl_override     = var.cache_ttl_override
  default_root_object    = var.default_root_object
  add_response_headers   = var.add_response_headers
  hsts_max_age           = var.hsts_max_age
  basic_auth_username    = var.basic_auth_username
  basic_auth_password    = var.basic_auth_password
  basic_auth_realm       = var.basic_auth_realm
  basic_auth_body        = var.basic_auth_body
  lambda_logging_enabled = var.lambda_logging_enabled
  tags                   = var.tags

  # When enabled, our client-side routing should handle all URL's that don't point to a physical file on S3.
  # These overrides ensure that when S3 responds with 404, it gets turned into a 200.
  override_response_code   = var.client_side_routing ? 200 : null
  override_response_status = var.client_side_routing ? "OK" : null
  override_only_on_code    = var.client_side_routing ? "404" : null
}
