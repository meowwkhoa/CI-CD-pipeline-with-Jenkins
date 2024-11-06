// Variables to use across the project
// which can be accessed by var.project_id
variable "project_id" {
  description = "The project ID to host the cluster in"
  default     = "decent-mariner-412114"
}

variable "region" {
  description = "The region the cluster in"
  default     = "us-east-1"
}

# variable "bucket" {
#   description = "S3 bucket for MLE course"
#   default     = "mle-course"
# }