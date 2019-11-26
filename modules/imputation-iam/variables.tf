variable "name_prefix" {
  description = "A name prefix used in resource names to ensure uniqueness across accounts"
  default     = "imputation-example"
  type        = string
}

variable "tags" {
  description = "Tags applied to all supported resources in module"
  default     = {}
  type        = map(string)
}
