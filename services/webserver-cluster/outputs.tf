# PROJECT NAME: cspiner v1.0
#____________________________________________________
# Web Server Clusters With File Layout Isolation and file layout isolation:         
#____________________________________________________
# This file contains the main resources of the project
# Author: Kennedy .N
#____________________________________________________

#_________MODULE::::::outputs____________

#____________________________________________________

output "load_balancer_type" {
    value = aws_lb.example.load_balancer_type
    description = "The Type of the load balancer"

  
}

output "alb_dns_name" {
    value = aws_lb.example.dns_name
    description = "The domain name of the load balancer"
  
}

output "asg_name" {
    value = aws_autoscaling_group.example.name
    description = "The Auto Scaling Group name"
  
}



output "alb_security_group_id" {
  value       = aws_security_group.alb.id
  description = "The ID of the Security Group attached to the load balancer"
}
