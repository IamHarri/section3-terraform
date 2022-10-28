output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "ec2_public_ip" {
  value = aws_instance.instance.public_ip
}