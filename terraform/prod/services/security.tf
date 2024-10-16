resource "aws_security_group" "prebid_server_instance_sg" {
  name        = "prebid_server_instance_sg"
  description = "Security group for Prebid Server"
  vpc_id      = data.terraform_remote_state.vpc.outputs.prebid_server_vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { 
    Name = "prebid_server_instance_sg"
    Env = "production"
  }
}
