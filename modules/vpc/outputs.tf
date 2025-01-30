output "vpc_id" {
  value = aws_vpc.infrasample.id
}

output "public_subnets" {
  description = "Will be used by the Web Server Module to see the subnet_ids"
  value = [
    aws_subnet.infrasamplePublicSubnet1,
    aws_subnet.infrasamplePublicSubnet2
  ]
}

output "private_subnets" {
  description = "Will be used by RDS Module to set the subnet_ids"
  value = [
    aws_subnet.infrasamplePrivateSubnet1,
    aws_subnet.infrasamplePrivateSubnet2
  ]
}
