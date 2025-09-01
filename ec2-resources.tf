# Public subnet EC2 instance 1
# Make sure to put your own key and ami
resource "aws_instance" "two-tier-web-server-1" {
  ami             = "ami-0360c520857e3138f"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.two-tier-ec2-sg.id]
  subnet_id       = aws_subnet.pub_sub_1a.id
  key_name   = "my-key"

  tags = {
    Name = "two-tier-web-server-1"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install apache2 -y
              systemctl start apache2
              systemctl enable apache2
              echo "<h1>Hello from Apache2 on 2nd EC2</h1>" > /var/www/html/index.html
              EOF
}

# Public subnet  EC2 instance 2
# Make sure to put your own key and ami
resource "aws_instance" "two-tier-web-server-2" {
  ami             = "ami-0360c520857e3138f"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.two-tier-ec2-sg.id]
  subnet_id       = aws_subnet.pub_sub_1b.id
  key_name   = "my-key"

  tags = {
    Name = "two-tier-web-server-2"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install apache2 -y
              systemctl start apache2
              systemctl enable apache2
              echo "<h1>Hello from Apache2 on 1st EC2</h1>" > /var/www/html/index.html
              EOF
}