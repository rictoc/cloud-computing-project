resource "aws_instance" "test_instance" {
  ami           = "ami-08d70e59c07c61a3a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet[0].id

  tags = {
    Name = "Test EC2 instance"
  }
}
