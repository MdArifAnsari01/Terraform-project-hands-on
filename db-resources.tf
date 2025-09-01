# RDS MYSQL database
resource "aws_db_instance" "two-tier-db-1" {
  allocated_storage           = 5
  storage_type                = "gp2"
  engine                      = "mysql"
  engine_version              = "5.7"
  instance_class              = "db.t3.micro"
  db_subnet_group_name        = "two-tier-db-sub"
  vpc_security_group_ids      = [aws_security_group.two-tier-db-sg.id]
  parameter_group_name        = "default.mysql5.7"
  db_name                     = "two_tier_db1"
  username                    = "admin"
  password                    = "password"
  multi_az                    = false
  skip_final_snapshot         = true
}