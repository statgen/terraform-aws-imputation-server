variable "bootstrap_script_args" {
  description = "Arguments to bootstrap script"
  default     = []
  type        = list(string)
}

variable "bootstrap_script_path" {
  description = "Path to EMR cluster bootstrap script to install imputation software"
  default     = ""
  type        = string
}

variable "public_key" {
  description = "RSA public key used for AWS key pair for EMR master node"
  default     = ""
  type        = string
}
