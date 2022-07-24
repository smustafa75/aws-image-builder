resource "random_id" "log_group_id" {
  byte_length = 2

}

resource "aws_vpc" "img-bldr-vpc" {
  cidr_block = "172.31.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "img-bldr-vpc"
  }
}

resource "aws_internet_gateway" "imgbldr-gw" {
  vpc_id = aws_vpc.img-bldr-vpc.id

  tags = {
    Name ="img-bldr-vpc-IGW"
  }
}

resource "aws_subnet" "img-bldr-public-net" {
  vpc_id = aws_vpc.img-bldr-vpc.id
  cidr_block = "172.31.11.0/24"
  map_public_ip_on_launch=true
  availability_zone = "us-east-1b"
  tags = {
    Name ="public subnet"
  }
}

resource "aws_route_table" "img-bldr-public-rt"{
vpc_id = aws_vpc.img-bldr-vpc.id
route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.imgbldr-gw.id
}


}

resource "aws_route_table_association" "public-assoc"{
  subnet_id = aws_subnet.img-bldr-public-net.id
  route_table_id = aws_route_table.img-bldr-public-rt.id
}

resource "aws_subnet" "img-bldr-private-net" {
  vpc_id = aws_vpc.img-bldr-vpc.id
  cidr_block = "172.31.12.0/24"
  map_public_ip_on_launch=false
  availability_zone = "us-east-1b"
  tags = {
    Name ="private subnet"
  }
}

resource "aws_route_table" "img-bldr-private-rt"{
vpc_id = aws_vpc.img-bldr-vpc.id
route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.img-bldr-nat-gw.id
}


}

resource "aws_route_table_association" "private-assoc"{
  subnet_id = aws_subnet.img-bldr-private-net.id
  route_table_id = aws_route_table.img-bldr-private-rt.id
}


resource "aws_eip" "img-bldr-eip"{
  vpc=true
}

resource "aws_nat_gateway" "img-bldr-nat-gw" {
allocation_id = aws_eip.img-bldr-eip.id
subnet_id = aws_subnet.img-bldr-public-net.id

depends_on = [
  aws_eip.img-bldr-eip,
  aws_subnet.img-bldr-public-net

]

}

resource "aws_security_group" "img-bldr-sg-inst" {
  name        = "EC2 Instances"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.img-bldr-vpc.id

  tags = {
    Name = "allow_traffic_to_ep"
  }
    depends_on = [
    aws_security_group.img-bldr-sg-ep
  ]
}

resource "aws_security_group_rule" "img-bldr-sg-inst-rule01" {
    type="egress"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    source_security_group_id= aws_security_group.img-bldr-sg-ep.id
    security_group_id= aws_security_group.img-bldr-sg-inst.id
  
}

resource "aws_security_group_rule" "img-bldr-sg-inst-rule02" {
    type="egress"
    from_port        = "0"
    to_port          = "0"
    protocol         = "-1"
    prefix_list_ids = [aws_vpc_endpoint.s3-endpt.prefix_list_id]
    security_group_id= aws_security_group.img-bldr-sg-inst.id
  
}


resource "aws_security_group_rule" "img-bldr-sg-inst-rule03" {
    type="egress"
    from_port        = "0"
    to_port          = "0"
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    security_group_id= aws_security_group.img-bldr-sg-inst.id
  
}

resource "aws_security_group" "img-bldr-sg-ep" {
  name        = "Endpoints SG"
  description = "Allow TLS inbound traffic from EC2 to EP"
  vpc_id      = aws_vpc.img-bldr-vpc.id

  tags = {
    Name = "allow_ec2_with_private_ep"
  }

}

resource "aws_security_group_rule" "img-bldr-sg-ep-rule01" {
  type="ingress"
    description      = "Allow from EC2 SG"
    from_port        = "0"
    to_port          = "65535"
    protocol         = "-1"
    security_group_id= aws_security_group.img-bldr-sg-ep.id
    source_security_group_id= aws_security_group.img-bldr-sg-inst.id
}

resource "aws_security_group_rule" "img-bldr-sg-ep-rule02" {
  type="ingress"
    description      = "Allow from VPC Traffic"
    from_port        = "443"
    to_port          = "443"
    protocol         = "tcp"
    cidr_blocks      =[ aws_vpc.img-bldr-vpc.cidr_block ]
    security_group_id= aws_security_group.img-bldr-sg-ep.id

}

resource "aws_security_group_rule" "img-bldr-sg-ep-rule03" {
  type="egress"
    from_port        = "0"
    to_port          = "65535"
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    security_group_id= aws_security_group.img-bldr-sg-ep.id  
  }

resource "aws_security_group_rule" "img-bldr-sg-ep-rule04" {
  type="egress"
    from_port        = "0"
    to_port          = "0"
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    security_group_id= aws_security_group.img-bldr-sg-ep.id
    
  
  }


resource "aws_vpc_endpoint" "kms-endpt" {
  vpc_id            = aws_vpc.img-bldr-vpc.id
  service_name      = "com.amazonaws.${var.region_info}.kms"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.img-bldr-sg-ep.id,
  ]
  subnet_ids = [aws_subnet.img-bldr-private-net.id]

  private_dns_enabled = true
  #tags = var.tags
}

resource "aws_vpc_endpoint" "ec2-msgs-endpt" {
  vpc_id            = aws_vpc.img-bldr-vpc.id
  service_name      = "com.amazonaws.${var.region_info}.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.img-bldr-sg-ep.id,
  ]
  subnet_ids = [aws_subnet.img-bldr-private-net.id]

  private_dns_enabled = true
  #tags = var.tags
}

resource "aws_vpc_endpoint" "s3-endpt" {
  vpc_id            = aws_vpc.img-bldr-vpc.id
  service_name      = "com.amazonaws.${var.region_info}.s3"
  vpc_endpoint_type = "Gateway"

  private_dns_enabled = false
#  tags = var.tags
}

resource "aws_vpc_endpoint_route_table_association" "s3Routing" {
  route_table_id  = aws_route_table.img-bldr-private-rt.id
  vpc_endpoint_id = aws_vpc_endpoint.s3-endpt.id
}

resource "aws_vpc_endpoint" "ssm-endpt" {
  vpc_id            = aws_vpc.img-bldr-vpc.id
  service_name      = "com.amazonaws.${var.region_info}.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.img-bldr-sg-ep.id,
  ]
  subnet_ids = [aws_subnet.img-bldr-private-net.id]

  private_dns_enabled = true
  #tags = var.tags
}
resource "aws_vpc_endpoint" "ssm-msgs-endpt" {
  vpc_id            = aws_vpc.img-bldr-vpc.id
  service_name      = "com.amazonaws.${var.region_info}.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.img-bldr-sg-ep.id,
  ]
  subnet_ids = [aws_subnet.img-bldr-private-net.id]

  private_dns_enabled = true
  #tags = var.tags
}


resource "aws_flow_log" "flow_log_config" {
  iam_role_arn    = aws_iam_role.imgbldr-vpc-flow-log-role.arn
  log_destination = var.s3_log_bucket
  log_destination_type ="s3"
  max_aggregation_interval = 60
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.img-bldr-vpc.id
}

resource "aws_cloudwatch_log_group" "imgbldr-vpc-flow-log" {
  name = "imgbldr-vpc-flow-log-${random_id.log_group_id.dec}"
}

resource "aws_iam_role" "imgbldr-vpc-flow-log-role" {
  name = "imgbldr-vpc-flow-log-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "img-bldr-vpc-flow-log-policy" {
  name = "img-bldr-vpc-flow-log-policy"
  role = aws_iam_role.imgbldr-vpc-flow-log-role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


