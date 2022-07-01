resource "aws_s3_bucket" "bucket" {
  bucket = "cc-project-load-test-bucket"
}

resource "aws_s3_bucket_acl" "models_bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_object" "test_images_upload" {
  for_each = fileset("test-images", "*")

  bucket = aws_s3_bucket.bucket.bucket
  key    = "test-images/${each.value}"
  source = "test-images/${each.value}"
  etag   = filemd5("test-images/${each.value}")
}

resource "aws_s3_bucket_object" "test_script_upload" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "locustfile.py"
  source = "./locustfile.py"
  etag   = filemd5("./locustfile.py")
}

resource "aws_security_group" "ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_instance" "load_test_instance" {
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.large"
  subnet_id     = var.subnet_id
  iam_instance_profile = "LabInstanceProfile"
  security_groups = [aws_security_group.ssh.id]
  key_name = "vockey"

  user_data = <<-EOT
    #!/bin/bash
    sudo amazon-linux-extras install python3
    python3 -m pip install locust
    mkdir /home/ec2-user/locust
    aws s3 sync s3://${aws_s3_bucket.bucket.bucket} /home/ec2-user/locust
  EOT

  tags = {
    "Name" = "Load generator instance"
  }
}
