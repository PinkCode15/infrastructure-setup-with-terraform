provider "aws" {
  region     =  var.region
  access_key = var.provider_access_key
  secret_key = var.provider_secret_key
}

# SETUP VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name = "MyVPC"
  }
}

# resource "aws_subnet" "public_subnet_az1" {
#   vpc_id            = aws_vpc.my_vpc.id
#   cidr_block        = "10.0.1.0/24"
#   availability_zone = var.availability_zones[0]
#   tags = {
#     Name = "PublicSubnetAZ1"
#   }
# }

# resource "aws_subnet" "public_subnet_az2" {
#   vpc_id            = aws_vpc.my_vpc.id
#   cidr_block        = "10.0.2.0/24"
#   availability_zone = var.availability_zones[1]

#   tags = {
#     Name = "PublicSubnetAZ2"
#   }
# }

# SETUP SUBNET
resource "aws_subnet" "public_subnet" {
    count             = var.subnet_count
    vpc_id            = aws_vpc.my_vpc.id
    cidr_block        = element(var.subnet_cidr_block, count.index % length(var.subnet_cidr_block))
    availability_zone = element(var.availability_zones, count.index % length(var.availability_zones))
    tags = {
        Name =  "PublicSubnet-${count.index + 1}"
    }
}

# SETUP INTERNET GATEWAY
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyInternetGateway"
  }
}

# SETUP SECURITY GROUP
resource "aws_security_group" "backend_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22 // SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // Allow SSH access from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] // Allow all outbound traffic
  }

  tags = {
    Name = "BackendSecurityGroup"
  }
}

resource "aws_security_group" "frontend_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80 // HTTP
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // Allow HTTP traffic from anywhere
  }

#   ingress {
#     from_port   = 443 // HTTPS
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] // Allow HTTPS traffic from anywhere
#   }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] // Allow all outbound traffic
  }

  tags = {
    Name = "FrontendSecurityGroup"
  }
}

# SETUP BACKEND SERVERS
resource "aws_instance" "backend_servers" {
  count         = var.backend_count
  instance_type = var.instance_type
  ami           = var.ami_id
  subnet_id     = element(aws_subnet.public_subnet[*].id, count.index % length(aws_subnet.public_subnet))
  security_groups = [aws_security_group.backend_sg.id]

  tags = {
    Name        = "BackendServer-${count.index + 1}"
    Environment = "Backend"
  }
}

# SETUP FRONTEND SERVERS
resource "aws_instance" "frontend_servers" {
  count         = var.frontend_count
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(aws_subnet.public_subnet[*].id, count.index % length(aws_subnet.public_subnet))
  security_groups = [aws_security_group.frontend_sg.id]

  tags = {
    Name        = "FrontendServer-${count.index + 1}"
    Environment = "Frontend"
  }
}

# SETUP S3 BUCKET
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "MyS3Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "my_bucket_versioning" {
  bucket = aws_s3_bucket.my_bucket.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

# resource "aws_s3_bucket_public_access_block" "my_bucket_public_access" {
#   bucket = aws_s3_bucket.my_bucket.bucket

#   block_public_acls   = true
#   block_public_policy = true
#   ignore_public_acls  = true
#   restrict_public_buckets = true
# }

# SETUP S3 BUCKET POLICY
resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "s3:GetObject"
        Effect = "Allow"
        Resource = "${aws_s3_bucket.my_bucket.arn}/*"
        Principal = "*"
      }
    ]
  })
}

# SETUP IAM USER
resource "aws_iam_user" "bob" {
  name = var.iam_username
  tags = {
    Description = var.iam_user_description
  }
}

resource "aws_iam_user_policy_attachment" "bob_policy_attachment" {
  user       = aws_iam_user.bob.name
  policy_arn = var.iam_policy_arn //aws_s3_bucket.my_bucket.arn
}






