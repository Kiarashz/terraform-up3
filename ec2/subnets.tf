# for cost optimization while creating HA infra, let's provision resources only in two zones
# let's use default public subnets where IGW is already attached
resource "aws_default_subnet" "public_az1" {
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "Default public subnet-1"
  }
}

resource "aws_default_subnet" "public_az2" {
  availability_zone = "ap-southeast-2b"

  tags = {
    Name = "Default public subnet-2"
  }
}

# create private subnets in each availability zone corresponding to the public subnets
resource "aws_subnet" "private_subnet_az1" {
  vpc_id            = data.aws_vpc.default.id
  cidr_block        = "172.31.64.0/24"
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_az2" {
  vpc_id            = data.aws_vpc.default.id
  cidr_block        = "172.31.65.0/24"
  availability_zone = "ap-southeast-2b"

  tags = {
    Name = "private-subnet-2"
  }
}
