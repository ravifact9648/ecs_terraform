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