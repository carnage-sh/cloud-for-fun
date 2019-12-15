resource "aws_eip" "loadbalancer" {
  vpc   = true
}

resource "aws_lb" "loadbalancer" {
  name               = random_id.key.hex
  internal           = false
  load_balancer_type = "network"

  subnet_mapping {
    subnet_id     = aws_subnet.public[0].id
    allocation_id = aws_eip.loadbalancer.id
  }
}

resource "aws_lb_listener" "listener_80" {
  load_balancer_arn       = aws_lb.loadbalancer.arn
  protocol            = "TCP_UDP"
  port                = 80
  default_action {
    target_group_arn = aws_lb_target_group.private_80.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "listener_22" {
  load_balancer_arn       = aws_lb.loadbalancer.arn
  protocol            = "TCP_UDP"
  port                = 22
  default_action {
    target_group_arn = aws_lb_target_group.private_22.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "private_80" {
  name                  = "${random_id.key.hex}-private-80"
  port                  = 80
  protocol              = "TCP_UDP"
  vpc_id                = aws_vpc.default.id
  target_type           = "instance"
  deregistration_delay  = 30
  health_check {
    interval            = 10
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "private_22" {
  name                  = "${random_id.key.hex}-private-22"
  port                  = 22
  protocol              = "TCP_UDP"
  vpc_id                = aws_vpc.default.id
  target_type           = "instance"
  deregistration_delay  = 30
  health_check {
    interval            = 10
    port                = 22
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group_attachment" "private_80" {
  target_group_arn  = aws_lb_target_group.private_80.arn
  port              = 80
  target_id         = aws_instance.private.id
}

resource "aws_lb_target_group_attachment" "private_22" {
  target_group_arn  = aws_lb_target_group.private_22.arn
  port              = 22
  target_id         = aws_instance.private.id
}

