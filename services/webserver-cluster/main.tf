# PROJECT NAME: cspiner v1.0
#____________________________________________________
# PROJECT DESCRIPTION : Web Server Clusters With File Layout Isolation and file layout isolation: 
#____________________________________________________
# This file contains the main resources of the project
# Author: Kennedy .N
#____________________________________________________

#_________MODULE::::::Main____________

#____________________________________________________

# Declare local Variables
locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}

# Create ec2 instance security group
resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"
}

# Define ingress rules for the ec2 instance created 
resource "aws_security_group_rule" "allow_http_inbound_instance" {
        security_group_id = aws_security_group.instance.id
        type        ="ingress"
        from_port   =var.server_port
        to_port     =var.server_port
        protocol    =local.tcp_protocol
        cidr_blocks =local.all_ips
}

# creating the aws launch configuration
resource "aws_launch_configuration" "example" {
    image_id = "ami-0d659ab07f0f08020"
    instance_type = var.instance_type
    security_groups = [aws_security_group.instance.id]
    # pass on the user data from disk
    user_data = templatefile("${path.module}/user-data.sh" , {
    server_port = var.server_port

    db_address=data.terraform_remote_state.db.outputs.address
    db_port=data.terraform_remote_state.db.outputs.port
})

    lifecycle {
      create_before_destroy = true
    }
  
}

# create the AWS auto scaling group
resource "aws_autoscaling_group" "example" {
    launch_configuration = aws_launch_configuration.example.name
    vpc_zone_identifier = data.aws_subnets.default.ids
    target_group_arns  = [aws_lb_target_group.asg.arn]
    health_check_type = "ELB"
    min_size = var.min_size
    max_size = var.max_size
    #name = "asg_lab"
    name = "${var.cluster_name}asg"

    tag {
        key = "Name"
        value = "${var.cluster_name}-kenlab"
        propagate_at_launch = true      
    }
  
}

# filter available subnets available from the default vpc
data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Deploying a load balancer for the cluster
resource "aws_lb" "example" {
    name = "${var.cluster_name}-lb"
    load_balancer_type = "application"
    subnets = data.aws_subnets.default.ids
    security_groups = [aws_security_group.alb.id]
  
}

# create a listener for the above load balancer
resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.example.arn
    port = local.http_port
    protocol = "HTTP"

    # By default, return a simple 404 page
    default_action {
      type = "fixed-response"

      fixed_response {
        content_type = "text/plain"
        message_body = "404: page not found. Check with your Dev Ops Engineer for the proper access ports"
        status_code = 404
      }

    }
  }

# Create Load balancer listener rules
resource "aws_lb_listener_rule" "asg" {
    listener_arn = aws_lb_listener.http.arn
    priority = 100

    condition {
      path_pattern {
        values = ["*"]

      }
    }
    action {
      type = "forward"
      target_group_arn = aws_lb_target_group.asg.arn
    }
  
}

# Create Load balancer security group
resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb"
}

# in-bound ingress rule
resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# out-bound ingress rule
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id
  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}


# Create a target group for the ASG using the aws_lb_target_group
resource "aws_lb_target_group" "asg" {
    #name     = "terraform-asg-example"
    name = "${var.cluster_name}target-group"
    port     = var.server_port
    protocol = "HTTP"
    vpc_id   = data.aws_vpc.default.id

    # The load balancer will periodically send http requests to the instances and will mark them as healthy if a response 200 is returned.. Otherwise mark them as unhealthy and stop sending traffic to it 
    health_check {
        path                = "/"
        protocol            = "HTTP"
        matcher             = "200"
        interval            = 15
        timeout             = 3
        healthy_threshold   = 2
        unhealthy_threshold = 2
  }  
}


  
