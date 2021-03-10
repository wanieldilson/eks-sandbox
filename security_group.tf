resource "aws_security_group" "demo-cluster" {
  name        = "terraform-eks-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.demo.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terraform-eks"
  }
}

# resource "aws_security_group" "demo-efs" {
#   name        = "terraform-efs"
#   description = "Communication to efs"
#   vpc_id      = aws_vpc.demo.id
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "terraform-efs"
#   }
# }


# resource "aws_security_group_rule" "demo-cluster-ingress-workstation-https" {
#   cidr_blocks       = [var.myip]
#   description       = "Allow workstation to communicate with the cluster API Server"
#   from_port         = 443
#   protocol          = "tcp"
#   security_group_id = aws_security_group.demo-cluster.id
#   to_port           = 443
#   type              = "ingress"
# }