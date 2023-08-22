resource "aws_ecr_repository" "awsomeapp" {
  name                 = "awsomeapp"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}
