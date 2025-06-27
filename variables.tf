variable "region" {
  description = "AWS region to deploy the infrastructure in"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instances"
  type        = string
}

variable "pem_key_name" {
  description = "Name of the PEM key for SSH access"
  type        = string
}

variable "pem_key_path" {
  description = "Full local file path to the PEM key for SSH access"
  type        = string
}

variable "large_instance_names" {
  description = "Names for the c5.4xlarge instances"
  type        = list(string)
  default     = ["sh1", "idx1", "idx2", "idx3"]
}

variable "medium_instance_names" {
  description = "Names for the t2.medium instances"
  type        = list(string)
  default     = ["licdeploy", "cmanager"]
}