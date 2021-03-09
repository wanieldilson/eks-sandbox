terraform {
  required_version = "> 0.13.0"
}

provider "aws" {
  alias   = "env"
  version = "~> 2.68"
  profile = var.environment

}

provider "http" {

}

provider "kubernetes" {
    
}

data "aws_availability_zones" "available" {
  state = "available"
}

 
resource "tls_private_key" "key" {
  algorithm   =  "RSA"
  rsa_bits    =  4096
}

resource "local_file" "key" {
  depends_on = [
    tls_private_key.key
  ]
  content         =  tls_private_key.key.private_key_pem
  filename        =  "webserver.pem"
}

resource "aws_key_pair" "key" {
   depends_on = [
    local_file.key
  ]
  key_name   = "eks-nodes"
  public_key = tls_private_key.key.public_key_openssh
}
