# SSM VPC Endpoints (Interface)
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.private_app[*].id
  security_group_ids = [aws_security_group.endpoints_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-${var.environment}-ssm-endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.private_app[*].id
  security_group_ids = [aws_security_group.endpoints_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2messages-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.private_app[*].id
  security_group_ids = [aws_security_group.endpoints_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-${var.environment}-ssmmessages-endpoint"
  }
}
