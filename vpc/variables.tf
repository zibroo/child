# variable "vpc_cidr_block" {
#     default = "10.0.0.0/16"
#     description = "The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using"
#     type = string
# }
# variable "name" {
#     default = "final-terraform"
#     description = "main name for tags"
#     type = string
# }
# variable "public_count" {
#     default = 2
#     description = "Count of public subnets"
#     type = number
# }
# variable "public_cidr" {
#     default = ["10.0.1.0/24","10.0.2.0/24"]
#     description = "The IPv4 CIDR block for the subnet"
#     type = list
# }
# variable "public_availability_zones" {
#     default = ["us-east-1a","us-east-1b"]
#     description = "AZ for the public subnet"
#     type = list
# }

# variable "private_count" {
#     default = 3
#     description = "Count of private subnets"
#     type = number
# }
# variable "private_cidr" {
#     default = ["10.0.10.0/24","10.0.11.0/24","10.0.12.0/24"]
#     description = "The IPv4 CIDR block for the private subnet"
#     type = list
# }
# variable "private_availability_zones" {
#     default = ["us-east-1a","us-east-1b","us-east-1c"]
#     description = "AZ for the private subnet"
#     type = list
# }

#####################################################

variable "networking" {
  type = object({
    cidr_block      = string
    region          = string
    vpc_name        = string
    azs             = list(string)
    public_subnets  = list(string)
    private_subnets = list(string)
    nat_gateways    = bool
  })
  default = {
   cidr_block       = "10.0.0.0/16"
   region          = "us-east-1"
   vpc_name         = "terraform-vpc"
   azs              = ["us-east-1a", "us-east-1b", "us-east-1c"]
   public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
   private_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]
   nat_gateways     = true
  }
}

variable "security_groups" {
  type = list(object({
    name        = string
    description = string
    ingress = list(object({
      description      = string
      protocol         = string
      from_port        = number
      to_port          = number
      cidr_blocks      = list(string)
      ipv6_cidr_blocks = list(string)
    }))
    egress = list(object({
      description      = string
      protocol         = string
      from_port        = number
      to_port          = number
      cidr_blocks      = list(string)
      ipv6_cidr_blocks = list(string)
    }))
  }))

   default = [{
    name        = "ssh"
    description = "Port 22"
    ingress = [{
      description      = "Allow SSH access"
      protocol         = "tcp"
      from_port        = 22
      to_port          = 22
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
    }]
    egress = [
      {
        description      = "Allow all outbound traffic"
        protocol         = "-1"
        from_port        = 0
        to_port          = 0
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
      }
    ]
  }]
  
}