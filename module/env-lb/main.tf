resource "aws_lb" "stage-lb" {
  name               = "stage-lb-sock"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.lb-sg
  subnets            = var.subnet3

  enable_deletion_protection = false
  tags = {
    Name = "stage-lb-sock"
  }
}

resource "aws_lb_target_group" "stage-tg" {
  name     = "stage-lb-sock-tg"
  port     = 30001
  protocol = "HTTP"
  vpc_id   = var.vpc

  health_check {
    interval = 30
    timeout = 5
    healthy_threshold = 3
    unhealthy_threshold = 5
  }
}

resource "aws_lb_target_group_attachment" "stage-tg-attach" {
  target_group_arn = aws_lb_target_group.stage-tg.arn
  target_id        = element(split(",", join(",","${var.instance}")),count.index)
  port             = 30001
  count=3
}

resource "aws_lb_listener" "stage-list" {
  load_balancer_arn = aws_lb.stage-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.stage-tg.arn
  }
}


resource "aws_lb" "prod-lb" {
  name               = "prod-lb-sock"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.lb-sg
  subnets            = var.subnet3

  enable_deletion_protection = false
  tags = {
    Name = "prod-lb-sock"
  }
}

resource "aws_lb_target_group" "prod-tg" {
  name     = "prod-lb-sock-tg"
  port     = 30002
  protocol = "HTTP"
  vpc_id   = var.vpc

  health_check {
    interval = 30
    timeout = 5
    healthy_threshold = 3
    unhealthy_threshold = 5
  }
}

resource "aws_lb_target_group_attachment" "prod-tg-attach" {
  target_group_arn = aws_lb_target_group.prod-tg.arn
  target_id        = element(split(",", join(",","${var.instance}")),count.index)
  port             = 30001
  count=3
}

resource "aws_lb_listener" "prod-list" {
  load_balancer_arn = aws_lb.prod-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod-tg.arn
  }
}