# Create Clasic Load Balancer #
resource "aws_elb" "web-elb" {
  name                      = "web-elb"
  subnets                   = aws_subnet.whiskey-public.*.id
  security_groups           = [aws_security_group.public-sg.id]
  cross_zone_load_balancing = true
  instances                 = aws_instance.Whiskey-WS[*].id
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
  tags = {
    Name = "web-elb"
  }
}