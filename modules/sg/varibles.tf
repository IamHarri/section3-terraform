variable "name" {
  type = string
  default = "allow http"
  description = "sg name"
}

variable "vpc_id" {
  type = string
}

variable "from_port" {
  type = number
  default = 80
}

variable "to_port" {
  type = number
  default = 80
}