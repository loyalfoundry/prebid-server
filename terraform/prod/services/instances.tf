locals {
  common_user_data = <<-EOF
    #!/bin/bash
    -ex
    # Update the instance
    sudo apt-get update
    echo ""
    echo "Installing CloudWatch agent"
    echo ""
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
    rpm -U amazon-cloudwatch-agent.rpm
    # Create the CloudWatch agent configuration file
    cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'CONFIG'
    {
        "metrics": {
            "append_dimensions": {
                "InstanceId": "$${aws:InstanceId}"
            },
            "metrics_collected": {
                "mem": {
                    "measurement": [
                        "%MEM"
                    ],
                    "metrics_collection_interval": 60
                }
            }
        }
    }
    CONFIG
    echo ""
    echo "Starting CloudWatch agent"
    echo ""
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
    echo ""
    echo ""
  EOF

  docker_user_data = <<-EOF
    echo ""
    echo "Installing Docker"
    echo ""
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce
    sudo systemctl start docker
    sudo usermod -aG docker ubuntu
    echo ""
    echo ""
    echo "Customer User Data Script Complete"
  EOF
}

resource "aws_key_pair" "deployer" {
   key_name = "loyal-devops-west-1"
   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCTVgPe1cRcBMVbZVAXyF11HuJF0myVpOj3WqJ2btWGDle6FtovExcxYgv6Lf2r0WB7ygYvOxv+KmeXTICfuAsbAI/wFttC4osOp0TmN6bsFEaam+nto8sOzaZXORXvxGvAgzSujte+N2dGszxWZHl21iqb8YRs9/YlkHlXVp5m5PFiWEh+WG0L29MVjnDQmD9acf4Ji0CwaxD176mK57f39dLsWAkTM2cyNIRURG6OXn19qZ4x2pGxjKJPBbrygTMK5Rk0L5U4fky/aX9g/j3OAIrATppWtNtqk6TSTfcg1t1BUcKYwzzoLwFyr2jHzBHq8+Z9Md0hbWjn0c7MGkkZ"
}

resource "aws_instance" "prebid_server" {
  ami                         = "ami-0cbd40f694b804622"
  instance_type               = "t3.large"
  key_name                    = aws_key_pair.deployer.key_name
  subnet_id                   = data.terraform_remote_state.vpc.outputs.prebid_server_subnet_1_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.prebid_server_instance_sg.id]

  tags = {
    Name = "prebid_server"
    Env  = "production"
  }
}

resource "aws_nat_gateway" "prebid_server_nat_gw" {
  allocation_id = aws_eip.prebid_server_nat_eip.id
  subnet_id     = data.terraform_remote_state.vpc.outputs.prebid_server_public_subnet_a_id

  tags = {
    Name = "prebid_server_nat_gw"
  }
}

resource "aws_eip" "prebid_server_nat_eip" {
  domain = "vpc"

  tags = {
    Name = "prebid_server_nat_eip"
  }
}

resource "aws_eip_association" "prebid_server_eip_association" {
  instance_id   = aws_instance.prebid_server.id
  allocation_id  = aws_eip.prebid_server_nat_eip.id
}

resource "aws_route_table" "prebid_server_private_rt" {
  vpc_id = data.terraform_remote_state.vpc.outputs.prebid_server_vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.prebid_server_nat_gw.id
  }

  tags = {
    Name = "prebid_server_private_rt"
  }
}

resource "aws_route_table_association" "prebid_server_private_rt_assoc" {
  subnet_id      = data.terraform_remote_state.vpc.outputs.prebid_server_subnet_1_id
  route_table_id = aws_route_table.prebid_server_private_rt.id
}

resource "aws_route_table_association" "prebid_server_private_rt_2_assoc" {
  subnet_id      = data.terraform_remote_state.vpc.outputs.prebid_server_subnet_2_id
  route_table_id = aws_route_table.prebid_server_private_rt.id
}
