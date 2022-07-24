output "vpc_id" {
  value = aws_vpc.img-bldr-vpc.id
}

output "public_net" {
  value = aws_subnet.img-bldr-public-net.id
}

output "private_net" {
  value = aws_subnet.img-bldr-private-net.id
}
output "sg" {
  value = aws_security_group.img-bldr-sg-inst.*.id
}

