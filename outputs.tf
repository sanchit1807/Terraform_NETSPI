#outputs
output "aws_s3_bucket_id" {
    value = aws_s3_bucket.S3_main.id
  
}
output "efs_id" {
  value = aws_efs_file_system.efs_main.id
}
output "ec2_instnace_id" {
  value = aws_instance.EC2_main.id
}
output "security_groups_id" {
    value = aws_security_group.sg_main.id
}
output "subnet_id" {
  value = aws_subnet.main.id
}
