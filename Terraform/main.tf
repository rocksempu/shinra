provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

resource "aws_instance" "frontend01" {
  ami = var.amis["us-east-1"]
  instance_type = "t2.micro"
  key_name = var.key_name
  tags = {
    Name = "frontend01"
  }
  vpc_security_group_ids = ["${aws_security_group.acesso-ssh.id}"]
}

resource "aws_instance" "frontend02" {
  ami = var.amis["us-east-1"]
  instance_type = "t2.micro"
  key_name = var.key_name
  tags = {
    Name = "frontend02"
  }
  vpc_security_group_ids = ["${aws_security_group.acesso-ssh.id}"]
}

resource "aws_instance" "backend01" {
  ami = var.amis["us-east-1"]
  instance_type = "t2.micro"
  key_name = var.key_name
  tags = {
    Name = "backend01"
  }
  vpc_security_group_ids = ["${aws_security_group.acesso-ssh.id}"]
  depends_on = [aws_dynamodb_table.dynamodb-prd]
}

resource "aws_instance" "backend02" {
  ami = var.amis["us-east-1"]
  instance_type = "t2.micro"
  key_name = var.key_name
  tags = {
    Name = "backend02"
  }
  vpc_security_group_ids = ["${aws_security_group.acesso-ssh.id}"]
  depends_on = [aws_dynamodb_table.dynamodb-prd]
}

resource "aws_s3_bucket" "s3-elblogs" {
  bucket = "s3-elblogs"
  acl    = "private"

  tags = {
    Name = "s3-elblogs"
  }
}

resource "aws_dynamodb_table" "dynamodb-prd" {
  name           = "GameScores"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "UserId"
  range_key      = "GameTitle"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "GameTitle"
    type = "S"
  }
}

resource "aws_elb" "elb-frontend" {
  name = "elb-frontend"
  subnets = ["subnet-576a9d08", "subnet-66a35347"]
  
  access_logs {
  bucket  = "aws_s3_bucket.s3-elblogs"
  enabled = true
  }

  listener {
    instance_port = 80
    instance_protocol = "tcp"
    lb_port = 80
    lb_protocol = "tcp"
  }

   listener {
      instance_port  = 443
      instance_protocol = "tcp"
      lb_port = 443
      lb_protocol = "tcp"
  }

    health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
    depends_on = [aws_s3_bucket.s3-elblogs]

/*
  instances                   = ["aws_instance.frontend01.id", "aws_instance.frontend02.id"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
*/

}

resource "aws_elb" "elb-backend" {
  name = "elb-backend"
  subnets = ["subnet-576a9d08", "subnet-66a35347"]
  
  access_logs {
  bucket  = "aws_s3_bucket.s3-elblogs"
  enabled = true
  }

  listener {
    instance_port     = 8000
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

   listener {
      instance_port  = 8000
      instance_protocol = "tcp"
      lb_port = 443
      lb_protocol = "tcp"
  }
  
    health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }
  depends_on = [aws_s3_bucket.s3-elblogs]
/*
  instances                   = ["aws_instance.backend01.id", "aws_instance.backend02.id"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
*/

}