
cat > vpc.tf << 'EOF'

#########################################
# PRIMARY VPC — us-east-1
#########################################

resource "aws_vpc" "primary" {
  provider             = aws.primary
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "logicworks-vpc-primary" }
}

# Internet Gateway — Primary
resource "aws_internet_gateway" "primary" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary.id
  tags     = { Name = "logicworks-igw-primary" }
}

# Public Subnet 1 — Primary (for ALB)
resource "aws_subnet" "primary_public_1" {
  provider                = aws.primary
  vpc_id                  = aws_vpc.primary.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "logicworks-public-1-primary" }
}

# Public Subnet 2 — Primary (for ALB)
resource "aws_subnet" "primary_public_2" {
  provider                = aws.primary
  vpc_id                  = aws_vpc.primary.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = { Name = "logicworks-public-2-primary" }
}

# Private Subnet 1 — Primary (for ECS)
resource "aws_subnet" "primary_private_1" {
  provider          = aws.primary
  vpc_id            = aws_vpc.primary.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "logicworks-private-1-primary" }
}

# Private Subnet 2 — Primary (for ECS)
resource "aws_subnet" "primary_private_2" {
  provider          = aws.primary
  vpc_id            = aws_vpc.primary.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1b"
  tags = { Name = "logicworks-private-2-primary" }
}

# NAT Gateway — Primary (allows private subnets to reach internet)
resource "aws_eip" "primary_nat" {
  provider = aws.primary
  domain   = "vpc"
  tags     = { Name = "logicworks-eip-primary" }
}

resource "aws_nat_gateway" "primary" {
  provider      = aws.primary
  allocation_id = aws_eip.primary_nat.id
  subnet_id     = aws_subnet.primary_public_1.id
  tags          = { Name = "logicworks-nat-primary" }
  depends_on    = [aws_internet_gateway.primary]
}

# Route Table — Public Primary
resource "aws_route_table" "primary_public" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary.id
  }
  tags = { Name = "logicworks-public-rt-primary" }
}

# Route Table — Private Primary
resource "aws_route_table" "primary_private" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.primary.id
  }
  tags = { Name = "logicworks-private-rt-primary" }
}

# Associations — Primary
resource "aws_route_table_association" "primary_pub1" {
  provider       = aws.primary
  subnet_id      = aws_subnet.primary_public_1.id
  route_table_id = aws_route_table.primary_public.id
}
resource "aws_route_table_association" "primary_pub2" {
  provider       = aws.primary
  subnet_id      = aws_subnet.primary_public_2.id
  route_table_id = aws_route_table.primary_public.id
}
resource "aws_route_table_association" "primary_priv1" {
  provider       = aws.primary
  subnet_id      = aws_subnet.primary_private_1.id
  route_table_id = aws_route_table.primary_private.id
}
resource "aws_route_table_association" "primary_priv2" {
  provider       = aws.primary
  subnet_id      = aws_subnet.primary_private_2.id
  route_table_id = aws_route_table.primary_private.id
}


#########################################
# SECONDARY VPC — us-west-2
#########################################

resource "aws_vpc" "secondary" {
  provider             = aws.secondary
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "logicworks-vpc-secondary" }
}

resource "aws_internet_gateway" "secondary" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary.id
  tags     = { Name = "logicworks-igw-secondary" }
}

resource "aws_subnet" "secondary_public_1" {
  provider                = aws.secondary
  vpc_id                  = aws_vpc.secondary.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = { Name = "logicworks-public-1-secondary" }
}

resource "aws_subnet" "secondary_public_2" {
  provider                = aws.secondary
  vpc_id                  = aws_vpc.secondary.id
  cidr_block              = "10.1.2.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
  tags = { Name = "logicworks-public-2-secondary" }
}

resource "aws_subnet" "secondary_private_1" {
  provider          = aws.secondary
  vpc_id            = aws_vpc.secondary.id
  cidr_block        = "10.1.10.0/24"
  availability_zone = "us-west-2a"
  tags = { Name = "logicworks-private-1-secondary" }
}

resource "aws_subnet" "secondary_private_2" {
  provider          = aws.secondary
  vpc_id            = aws_vpc.secondary.id
  cidr_block        = "10.1.11.0/24"
  availability_zone = "us-west-2b"
  tags = { Name = "logicworks-private-2-secondary" }
}

resource "aws_eip" "secondary_nat" {
  provider = aws.secondary
  domain   = "vpc"
  tags     = { Name = "logicworks-eip-secondary" }
}

resource "aws_nat_gateway" "secondary" {
  provider      = aws.secondary
  allocation_id = aws_eip.secondary_nat.id
  subnet_id     = aws_subnet.secondary_public_1.id
  tags          = { Name = "logicworks-nat-secondary" }
  depends_on    = [aws_internet_gateway.secondary]
}

resource "aws_route_table" "secondary_public" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary.id
  }
  tags = { Name = "logicworks-public-rt-secondary" }
}

resource "aws_route_table" "secondary_private" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.secondary.id
  }
  tags = { Name = "logicworks-private-rt-secondary" }
}

resource "aws_route_table_association" "secondary_pub1" {
  provider       = aws.secondary
  subnet_id      = aws_subnet.secondary_public_1.id
  route_table_id = aws_route_table.secondary_public.id
}
resource "aws_route_table_association" "secondary_pub2" {
  provider       = aws.secondary
  subnet_id      = aws_subnet.secondary_public_2.id
  route_table_id = aws_route_table.secondary_public.id
}
resource "aws_route_table_association" "secondary_priv1" {
  provider       = aws.secondary
  subnet_id      = aws_subnet.secondary_private_1.id
  route_table_id = aws_route_table.secondary_private.id
}
resource "aws_route_table_association" "secondary_priv2" {
  provider       = aws.secondary
  subnet_id      = aws_subnet.secondary_private_2.id
  route_table_id = aws_route_table.secondary_private.id
}
EOF
