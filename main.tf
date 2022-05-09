provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "protagona-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_iam_role" "role" {
  name = "protagona-iam-role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "policy" {
  name        = "protagona-s3-policy"
  description = "A test policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "protagona-instance-profile"
  role = aws_iam_role.role.name
}


resource "aws_launch_configuration" "protagona-LC" {
  name_prefix          = "protagona-launch_config"
  
  image_id             = data.aws_ami.ubuntu.id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.test_profile.id
  
  security_groups      = [aws_security_group.protagona.id]
  user_data            = "${file("webserverconfigs.sh")}"
  lifecycle {
    create_before_destroy = true
  }
  
}


resource "aws_autoscaling_group" "protagona-ASG" {
  name                      = "protagona-ASG"
  depends_on                = [aws_launch_configuration.protagona-LC]
  vpc_zone_identifier       = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
  max_size                  = 3
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.protagona-LC.id}"
  target_group_arns         = [aws_lb_target_group.protagona-TargetGroup.arn]


  lifecycle {
    create_before_destroy = true
  }
}




resource "aws_lb_target_group" "protagona-TargetGroup" {
  name        = "protagona-TG"
  depends_on  = [module.vpc.vpc_id]
  port        =  80
  protocol    = "HTTP"
  vpc_id      = "${module.vpc.vpc_id}"
  target_type = "instance"

  health_check {
    interval            = 30
    path                = "/index.html"
    port                = 80
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200,202"
  }
}

resource "aws_lb" "protagona-ALB" {
  name               = "protagona-ALB"
  subnets            = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb-sg.id] 
  
  
  
}

resource "aws_lb_listener" "protagona-ALB-Listener" {
  depends_on = [aws_lb.protagona-ALB, aws_lb_target_group.protagona-TargetGroup]
  load_balancer_arn = "${aws_lb.protagona-ALB.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.protagona-TargetGroup.arn}"
    type             = "forward"
  }
}


#security group ALB SG

resource "aws_security_group" "elb-sg" {
  vpc_id = module.vpc.vpc_id
  name = "terraform-sample-elb-sg"
  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Inbound HTTP from anywhere
  ingress {
    from_port   = var.elb_port
    to_port     = var.elb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




#launch config security group
resource "aws_security_group" "protagona" {
  name = "terraform-protagona-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}




