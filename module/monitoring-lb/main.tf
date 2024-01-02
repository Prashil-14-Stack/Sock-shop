resource "aws_lb" "prom-lb" {
  name               = "prom-lb-sock"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.k8s-sg
  subnets            = var.subnet4

  enable_deletion_protection = false
  tags = {
    Name = "stage-lb-sock"
  }
}

resource "aws_lb_target_group" "prom-tg" {
  name     = "prom-lb-sock-tg"
  port     = 31090
  protocol = "HTTP"
  vpc_id   = var.vpc

  health_check {
    interval = 30
    timeout = 5
    healthy_threshold = 3
    unhealthy_threshold = 5
  }
}

resource "aws_lb_target_group_attachment" "prom-tg-attach" {
  target_group_arn = aws_lb_target_group.prom-tg.arn
  target_id        = element(split(",", join(",","${var.instance}")),count.index)
  port             = 31090
  count=3
}

resource "aws_lb_listener" "prom-list" {
  load_balancer_arn = aws_lb.prom-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prom-tg.arn
  }
}


resource "aws_lb" "graf-lb" {
  name               = "graf-lb-sock"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.k8s-sg
  subnets            = var.subnet4

  enable_deletion_protection = false
  tags = {
    Name = "prod-lb-sock"
  }
}

resource "aws_lb_target_group" "graf-tg" {
  name     = "graf-lb-sock-tg"
  port     = 31300
  protocol = "HTTP"
  vpc_id   = var.vpc

  health_check {
    interval = 30
    timeout = 5
    healthy_threshold = 3
    unhealthy_threshold = 5
  }
}

resource "aws_lb_target_group_attachment" "graf-tg-attach" {
  target_group_arn = aws_lb_target_group.graf-tg.arn
  target_id        = element(split(",", join(",","${var.instance}")),count.index)
  port             = 31300
  count=3
}

resource "aws_lb_listener" "prod-list" {
  load_balancer_arn = aws_lb.graf-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.graf-tg.arn
  }
}