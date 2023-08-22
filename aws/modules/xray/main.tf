# resource "aws_xray_group" "main" {
#   group_name        = "${var.workload}-group"
#   filter_expression = "responsetime > 5"

#   insights_configuration {
#     insights_enabled      = true
#     notifications_enabled = true
#   }
# }
