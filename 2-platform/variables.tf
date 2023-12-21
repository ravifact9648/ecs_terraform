variable "region" {
  default = "eu-west-1"
  description = "AWS Region"
}

variable "remote_state_bucket" {
  description = "Remote State Bucket"
}
variable "remote_state_key" {
  description = "Remote State key"
}

variable "ecs_cluster_name" {
  description = "ECS Cluster Name"
}

variable "internet_cidr_block" {
  description = "Internet CIDR Block"
}

variable "ecs_domain_name" {
  description = "ECS Domain Name"
}