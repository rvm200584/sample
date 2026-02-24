# Windows: notepad providers.tf
# Mac/Linux:
cat > providers.tf << 'EOF'
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Primary Region — us-east-1
provider "aws" {
  alias  = "primary"
  region = "us-east-1"
}

# Secondary Region — us-west-2
provider "aws" {
  alias  = "secondary"
  region = "us-west-2"
}
EOF
