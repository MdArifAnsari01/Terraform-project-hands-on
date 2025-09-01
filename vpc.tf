resource "aws_vpc" "two-tier-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "two-tier-vpc"
  }
}

resource "aws_subnet" "pub_sub_1a" {
  vpc_id = aws_vpc.two-tier-vpc.id
  cidr_block = "10.0.0.0/18"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
    Name = "Pub-subnet-1a"
  }
}

resource "aws_subnet" "pub_sub_1b" {
  vpc_id = aws_vpc.two-tier-vpc.id
  cidr_block = "10.0.64.0/18"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
  tags = {
    Name = "Pub-subnet-1b"
  }
}

resource "aws_subnet" "pvt_sub_1a" {
  vpc_id = aws_vpc.two-tier-vpc.id
  cidr_block = "10.0.128.0/18"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1a"
  tags = {
    Name = "Pvt-subnet-1a"
  }
}

resource "aws_subnet" "pvt_sub_1b" {
  vpc_id = aws_vpc.two-tier-vpc.id
  cidr_block = "10.0.192.0/18"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1b"
  tags = {
    Name = "Pvt-subnet-1b"
  }
}

resource "aws_internet_gateway" "two-tier-igw" {
  tags = {
    Name = "two-tier-igw"
  }
  vpc_id = aws_vpc.two-tier-vpc.id
}

resource "aws_route_table" "two-tier-rt" {
  tags = {
    Name = "two-tier-rt-internet-access"
  }
  vpc_id = aws_vpc.two-tier-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.two-tier-igw.id
  }
}

resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.pub_sub_1a.id
  route_table_id = aws_route_table.two-tier-rt.id
}

resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.pub_sub_1b.id
  route_table_id = aws_route_table.two-tier-rt.id
}



# Creating load balancer
# Application Load Balancer
resource "aws_lb" "app_alb" {
  name               = "my-two-tier-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.two-tier-alb-sg.id]
  subnets            = [aws_subnet.pub_sub_1a.id, aws_subnet.pub_sub_1b.id] 

  enable_deletion_protection = false

  tags = {
    Environment = "dev"
    Name        = "two-tier-lb"
  }
}

# Target Group for ALB
resource "aws_lb_target_group" "two-tier-loadb-target" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  depends_on = [aws_vpc.two-tier-vpc]
  vpc_id   = aws_vpc.two-tier-vpc.id

  tags = {
    Name = "apptwo-tier-load_tg"
  }
}

# Listener for HTTP traffic
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.two-tier-loadb-target.arn
  }
}

resource "aws_lb_target_group_attachment" "two-tier-tg-attch-1" {
  target_group_arn = aws_lb_target_group.two-tier-loadb-target.arn
  target_id        = aws_instance.two-tier-web-server-1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "two-tier-tg-attch-2" {
  target_group_arn = aws_lb_target_group.two-tier-loadb-target.arn
  target_id        = aws_instance.two-tier-web-server-2.id
  port             = 80
}

# Subnet group database
resource "aws_db_subnet_group" "two-tier-db-sub" {
  name       = "two-tier-db-sub"
  subnet_ids = [aws_subnet.pvt_sub_1a.id, aws_subnet.pvt_sub_1b.id]
}

