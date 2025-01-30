resource "aws_security_group" "infrasampleWebSecGroup" {
  name        = "allow_ssh_http"
  description = "Allow ssh http inbound traffic"
  vpc_id      = var.infrasample_vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value["port"]
      to_port     = ingress.value["port"]
      protocol    = ingress.value["proto"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "infrasampleWebSecGroup"
    Project = "infrasample health"
  }
}

resource "aws_lb" "infrasampleLoadBalancer" {
  load_balancer_type = "application"
  subnets            = [var.infrasample_public_subnets[0].id, var.infrasample_public_subnets[1].id]
  security_groups    = [aws_security_group.infrasampleWebSecGroup.id]
  tags = {
    Name    = "infrasampleLoadBalancer"
    Project = "infrasample health"
  }
}

resource "aws_lb_listener" "infrasampleLbListener" {
  load_balancer_arn = aws_lb.infrasampleLoadBalancer.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.infrasampleTargetGroup.id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "infrasampleTargetGroup" {
  name     = "example-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.infrasample_vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name    = "infrasampleTargetGroup"
    Project = "infrasample health"
  }
}

resource "aws_lb_target_group_attachment" "webserver1" {
  target_group_arn = aws_lb_target_group.infrasampleTargetGroup.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "webserver2" {
  target_group_arn = aws_lb_target_group.infrasampleTargetGroup.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

resource "aws_instance" "webserver1" {
  ami                         = local.ami_id
  instance_type               = local.instance_type
  key_name                    = local.key_name
  subnet_id                   = var.infrasample_public_subnets[0].id
  security_groups             = [aws_security_group.infrasampleWebSecGroup.id]
  associate_public_ip_address = true

  # user_data = <<-EOF
  #             #!/bin/bash -xe
  #             sudo su
  #             yum update -y
  #             yum install -y httpd
  #             echo "<h1>Hello, World!</h1>server: infrasampleWebServer1" > /var/www/html/index.html
  #             echo "healthy" > /var/www/html/hc.html
  #             service httpd start
  #             EOF

}

resource "aws_instance" "webserver2" {
  ami                         = local.ami_id
  instance_type               = local.instance_type
  key_name                    = local.key_name
  subnet_id                   = var.infrasample_public_subnets[0].id
  security_groups             = [aws_security_group.infrasampleWebSecGroup.id]
  associate_public_ip_address = true

  # user_data = <<-EOF
  #             #!/bin/bash -xe
  #             sudo su
  #             yum update -y
  #             yum install -y httpd
  #             echo "<h1>Hello, World!</h1>server: infrasampleWebServer2" > /var/www/html/index.html
  #             echo "healthy" > /var/www/html/hc.html
  #             service httpd start
  #             EOF
}
