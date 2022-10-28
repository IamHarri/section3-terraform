variable "tag" {
  default     = "terraform-vpc1"
  type        = string
  description = "this is tag"

}

variable "ec2_instance_type" {
  default     = "t2.micro"
  type        = string
  description = "instance type"
}

variable "key_name" {
  default     = "ansible"
  type        = string
  description = "key pem name"
}