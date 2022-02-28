#################################
# DATA
#################################
data "aws_ami" "aws-ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

##################################
## RESOURCES
##################################
resource "tls_private_key" "p_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "whiskey1"
  public_key = tls_private_key.p_key.public_key_openssh
}



# Launch WEB server instances #
resource "aws_instance" "Whiskey-WS" {
  count                       = var.instance_count
  ami                         = data.aws_ami.aws-ubuntu.id
  instance_type               = var.instance_type
  availability_zone           = var.availability_zone[count.index]
  subnet_id                   = element(aws_subnet.whiskey-public.*.id, count.index)
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.public-sg.id]
  key_name                    = aws_key_pair.generated_key.key_name
#  user_data                   = file("./userData_script.sh")
  user_data = <<-EOF
      #! /bin/bash
      sudo apt-get update
      sudo apt-get install -y nginx
      sudo systemctl start nginx
      sudo systemctl enable nginx
      echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
  EOF
  tags = {
    Name    = "Whiskey-WS${count.index + 1}"
    Owner   = "Whiskey"
    purpose = "Grandpa's Whiskey Web Server"
  }
}
# Launch DB server instances #
resource "aws_instance" "Whiskey-DB" {
  count                       = var.instance_count
  ami                         = data.aws_ami.aws-ubuntu.id
  instance_type               = var.instance_type
  availability_zone           = var.availability_zone[count.index]
  subnet_id                   = element(aws_subnet.whiskey-private.*.id, count.index)
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.private-sg.id]
  key_name                    = aws_key_pair.generated_key.key_name
  tags = {
    Name    = "Whiskey-DB${count.index + 1}"
    Owner   = "Whiskey"
    purpose = "Grandpa's Whiskey Data Base"
  }
}

resource "aws_ebs_volume" "ebs-volume" {
  count             = var.instance_count
  availability_zone = element(var.availability_zone, count.index)
  size              = 20
  type              = "gp2"
  tags = {
    Name = "extra volume data"
  }
}

resource "aws_volume_attachment" "ebs-volume-1-attachment" {
  count       = var.instance_count
  device_name = element(var.ec2_device_names, count.index)
  volume_id   = aws_ebs_volume.ebs-volume.*.id[count.index]
  instance_id = aws_instance.Whiskey-WS.*.id[count.index]
}

