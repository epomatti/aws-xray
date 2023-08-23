resource "aws_xray_sampling_rule" "myapp_001" {
  rule_name      = "MyApp001"
  priority       = 100
  version        = 1
  reservoir_size = 1
  fixed_rate     = 0.05
  url_path       = "/api/*"
  host           = "*"
  http_method    = "*"
  service_type   = "*"
  service_name   = "MyApp"
  resource_arn   = "*"
}
