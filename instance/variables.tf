variable "instance_count" {
  default = 1
}
variable "ami" {
  type = string
  default =  null
}
variable "instance_os" {
  type = string 
  default = "ubuntu"
}
variable "subnet_id" {

}
variable "instance_type" {
  type = string 
  default = "t2.micro"
}
variable "name" {
  
}
variable "ingress_rules" {
    type = list 
    default = [
    { port = 80, cidr_block = ["0.0.0.0/0"] },
    { port = 443, cidr_block = ["0.0.0.0/0"] },
    { port = 22, cidr_block = ["0.0.0.0/0"] }
  ]
  
}
variable "vpc_id" {
  
}
variable "ebs_volume_size" {
  default = 10 
  type = number
  
}
