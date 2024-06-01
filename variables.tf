variable "provider_access_key" {
  description = "The provider access key for the infrastructure"
}

variable "provider_secret_key" {
  description = "The provider secret key for the infrastructure"
}

variable "instance_type" {
  description = "The type of EC2 instance to launch"
  default     = "t2.micro"
}

variable "ami_id" {
  description = "The type of AMI"
  default     = "ami-053a617c6207ecc7b"
}

variable "availability_zones" {
  description = "List of availability zones to deploy resources"
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "region" {
  description = "AWS region"
  default     = "eu-west-2"
}

variable "cidr_block" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for subnet"
  default     =  ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "subnet_count" {
  description = "Number of subnets."
  default     = 2
}

variable "backend_count" {
  description = "Number of backend servers."
  default     = 4
}

variable "frontend_count" {
  description = "Number of frontend servers."
  default     = 2
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  default     = "stacey-project-bucket-1"
}

# variable "s3_bucket_policy" {
#   description = "S3 bucket policy."
#   default     = "" // Add your policy here if needed
# }

variable "iam_username" {
  description = "Name of the IAM user"
  default     = "BOB"
}

variable "iam_user_description" {
  description = "Description of the IAM user."
  default     = "CTO"
}

variable "iam_policy_arn" {
  description = "ARN of the IAM policy to attach to the user."
  default     = "arn:aws:iam::aws:policy/AdministratorAccess"
}

