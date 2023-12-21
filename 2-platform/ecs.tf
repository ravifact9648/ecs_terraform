provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {}
}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"

  config = {
    region = var.region
    bucket = var.remote_state_bucket
    key    = var.remote_state_key
  }
}

### Creating ECS Cluster
resource "aws_ecs_cluster" "production-fargate-cluster" {
  name = "Production-Fargate-Cluster"
}

### application Load Balancer
resource "aws_alb" "ecs-cluster-alb" {
  name = "${var.ecs_cluster_name}-ALB"
  internal = false
  security_groups = [aws_security_group.ecs_alb_security_group.id]
  subnets = [split(",", join(",",data.terraform_remote_state.infrastructure.public_subnets))]

  tags = {
    Name = "${var.ecs_cluster_name}-ALB"
  }
}

### AWS Route 53 Record
resource "aws_route53_record" "aws-alb-record" {
  name    = "*.${var.ecs_domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.ecs_domain.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_alb.ecs-cluster-alb.dns_name
    zone_id                = aws_alb.ecs-cluster-alb.zone_id
  }
}

###Default target group aws alb
resource "aws_alb_target_group" "ecs_default_target_group" {
  name = var.ecs_cluster_name+"- TG"
  port = 80
  protocol = "HTTPS"
  vpc_id = data.terraform_remote_state.infrastructure.vpc_id

  tags = {
    Name = var.ecs_cluster_name+"- TG"
  }
}

### Listener For Load Balancer
resource "aws_alb_listener" "ecs_alb_https_listner" {
  load_balancer_arn = aws_alb.ecs-cluster-alb.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn = aws_acm_certificate.ecs-domain-certificate.arn
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.ecs_default_target_group.arn
  }

  depends_on = ["aws_alb_target_group.ecs_default_target_group"]
}

### Creating IAM Role for ECS Cluster
resource "aws_iam_role" "ecs_cluster_role" {
  name = var.ecs_cluster_name+"-IAM Role"
  assume_role_policy = <<EOF
  "version" : "2012-10-17",
"Statement" : [
{
  "Effect" : "Allow",
  "Principal" : {
    "Services" : ["ecs.amazonaws.com", "ec2.amazonaws.com", "application-autoscaling.amazonaws.com"]
    },
  "Action": "sts:AssumeRole"
}
]
}
EOF
}

### Iam Role Policy
resource "aws_iam_role_policy" "ecs_cluster_policy" {
  name = var.ecs_cluster_name+" - IAM Policy"
  role   = aws_iam_role.ecs_cluster_role.id
  policy = <<EOF
"Version" : "2012-10-17",
"Statement": [
{
  "Effect":"Allow",
"Action": [
"ecs:*",
"ec2:*",
"elasticloadbalancing:*",
"ecr:*",
"dynamodb:*",
"s3:*",
"rds:*",
"sqs:*",
"sns:*",
"logs:*",
"ssm:*"
],
"Resouces": "*"
}
]
}
  EOF
}

