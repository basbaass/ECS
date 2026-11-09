#VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Project = "gatus"
  }
}
##IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Project = "gatus"
  }
}
###subnet A --pub
resource "aws_subnet" "subnet_a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  availability_zone = var.availability_zones[0]

  tags = {
    Project = "public"
  }
}
###subnet B --pub

resource "aws_subnet" "subnet_b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  availability_zone = var.availability_zones[1]

  tags = {
    Project = "gatus"
  }
}

###subnet C -- priv
resource "aws_subnet" "subnet_c" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"

  availability_zone = var.availability_zones[0]

  tags = {
    Project = "gatus"
  }
}
###subnet D -- priv 
resource "aws_subnet" "subnet_d" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"

  availability_zone = var.availability_zones[1]

  tags = {
    Project = "gatus"
  }
}


#EIP A

resource "aws_eip" "nat_a" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

#EIP B

resource "aws_eip" "nat_b" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

#NAT A

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.subnet_a.id

  tags = {
    Project = "gatus"
  }

  depends_on = [aws_internet_gateway.igw]
}

#NAT B

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.subnet_b.id

  tags = {
    Project = "gatus"
  }

  depends_on = [aws_internet_gateway.igw]
}

#Public route table A+B

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Project = "gatus"
  }
}

#Private route table C

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_a.id
  }

  tags = {
    Project = "gatus"
  }
}

#Private route table D
resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_b.id
  }

  tags = {
    Project = "gatus"
  }
}

#Route table association A
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.public_route.id
}
#Route table association B
resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.public_route.id
}
#Route table association C
resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.subnet_c.id
  route_table_id = aws_route_table.private_a.id
}
#Route table association D

resource "aws_route_table_association" "private_d" {
  subnet_id      = aws_subnet.subnet_d.id
  route_table_id = aws_route_table.private_b.id
}
