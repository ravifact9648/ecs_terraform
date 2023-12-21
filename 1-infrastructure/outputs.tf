output "vpc_id" {
  value = aws_vpc.production_vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.production_vpc.cidr_block
}

output "public_subnet_id_1" {
  value = aws_subnet.public-subnet-1.id
}

output "public_subnet_id_2" {
  value = aws_subnet.public-subnet-2.id
}

output "public_subnet_id_3" {
  value = aws_subnet.public-subnet-3.id
}

output "private_subnet_id_1" {
  value = aws_subnet.private-subnet-1.id
}

output "private_subnet_id_2" {
  value = aws_subnet.private-subnet-2.id
}

output "private_subnet_id_3" {
  value = aws_subnet.private-subnet-3.id
}