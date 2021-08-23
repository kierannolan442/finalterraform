resource "aws_lb" "test" {
  name               = "terraformLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_ssh.id]
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]   
}

resource "aws_lb_target_group" "test" {
  name     = "terraformtarget"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.terraform.id
}
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

resource "aws_autoscaling_group" "terraform" {
  name                      = "terraformASG"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = false
  launch_configuration      = "terraformLC"
  vpc_zone_identifier       = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  tag {
    key                 = "Environment"
    value               = "Terraform"
    propagate_at_launch = false
  }
}