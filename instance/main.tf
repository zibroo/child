##################################################################################################################################
# EC2 INSTANCES
##################################################################################################################################
resource "aws_instance" "instance" {
  count = var.instance_count
  ami                         = var.ami
  subnet_id                   = var.subnet_id
  instance_type               = var.instance_type 
  associate_public_ip_address = true
  vpc_security_group_ids = [ aws_security_group.sg.id]
  tags = {
    Name = "instances"
  }
  user_data = file("${path.module}/script.sh")
}

##################################################################################################################################
# SECURITY GROUP
##################################################################################################################################
resource "aws_security_group" "sg" {
  vpc_id = var.vpc_id



  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ingress.value.cidr_block
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "terraform-sg"
  }
}
##################################################################################################################################
# LAUNCH TEMPLATE
##################################################################################################################################



