resource "aws_db_subnet_group" "infrasampleDBSubnetGroup" {
  name = "infrasample-db-subnet_group"
  subnet_ids = [
    var.infrasample_private_subnets[0].id,
    var.infrasample_private_subnets[1].id
  ]
  tags = {
    Name    = "infrasampleDBSubnetGroup"
    Project = "infrasample health"
  }

}

resource "aws_security_group" "infrasampleDBSecurityGroup" {
  name   = "infrasample-db-security_group"
  vpc_id = var.infrasample_vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      var.infrasample_private_subnets_cidrs[0],
      var.infrasample_private_subnets_cidrs[1]
    ]
  }
  tags = {
    Name    = "infrasampleDBSecurityGroup" 
    Project = "infrasample health"
  }
}

resource "aws_db_instance" "infrasampleRDS" {
  availability_zone      = var.db_az
  db_subnet_group_name   = aws_db_subnet_group.infrasampleDBSubnetGroup.name
  vpc_security_group_ids = [aws_security_group.infrasampleDBSecurityGroup.id]
  allocated_storage      = 20
  storage_type           = "standard"
  engine                 = "postgres"
  engine_version         = "12"
  instance_class         = "db.t2.micro"
  name                   = var.db_name
  username               = var.db_user_name
  password               = var.db_user_password
  skip_final_snapshot    = true
  tags = {
    Name    = "infrasampleRDS"
    Project = "infrasample health"
  }
}
