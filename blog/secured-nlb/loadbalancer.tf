resource "aws_eip" "loadbalancer" {
  count = var.private ? 1 : 0
  vpc   = true
}

resource "aws_lb" "loadbalancer" {
  count              = var.private ? 1 : 0
  name               = random_id.key.hex
  internal           = false
  load_balancer_type = "network"

  subnet_mapping {
    subnet_id     = aws_subnet.public[0].id
    allocation_id = aws_eip.loadbalancer[count.index].id
  }
}

resource "aws_lb_listener" "listener_80" {
  count             = var.private ? 1 : 0
  load_balancer_arn = aws_lb.loadbalancer[count.index].arn
  protocol          = "TCP_UDP"
  port              = 80
  default_action {
    target_group_arn = aws_lb_target_group.private_80[count.index].arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "listener_22" {
  count             = var.private ? 1 : 0
  load_balancer_arn = aws_lb.loadbalancer[count.index].arn
  protocol          = "TCP_UDP"
  port              = 22
  default_action {
    target_group_arn = aws_lb_target_group.private_22[count.index].arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "private_80" {
  count                = var.private ? 1 : 0
  name                 = "${random_id.key.hex}-private-80"
  port                 = 80
  protocol             = "TCP_UDP"
  vpc_id               = aws_vpc.default.id
  target_type          = "instance"
  deregistration_delay = 30
  health_check {
    interval            = 10
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "private_22" {
  count                = var.private ? 1 : 0
  name                 = "${random_id.key.hex}-private-22"
  port                 = 22
  protocol             = "TCP_UDP"
  vpc_id               = aws_vpc.default.id
  target_type          = "instance"
  deregistration_delay = 30
  health_check {
    interval            = 10
    port                = 22
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group_attachment" "private_80" {
  count            = var.private ? 1 : 0
  target_group_arn = aws_lb_target_group.private_80[count.index].arn
  port             = 80
  target_id        = aws_instance.private[count.index].id
}

resource "aws_lb_target_group_attachment" "private_22" {
  count            = var.private ? 1 : 0
  target_group_arn = aws_lb_target_group.private_22[count.index].arn
  port             = 22
  target_id        = aws_instance.private[count.index].id
}

