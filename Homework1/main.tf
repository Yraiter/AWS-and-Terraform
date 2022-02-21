provider "aws" {
  region      = "us-east-1"
#  profile     = "admin"
#  access_key = "AKIA425UHRIA75W6BTDP"
#  secret_key = "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"
  shared_credentials_files = ["/Users/test/.aws/credentials"]
  profile                 = "yair-admin"
}


#################################
# DATA
#################################
data "aws_ami" "aws-ubuntu" {
  most_recent = true
  owners = ["099720109477"]
  filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_vpc" "aws_vpc" {
  default = true
}

#################################
# RESOURCES
#################################

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.aws_vpc.aws_vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
#    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh & http"
  }
}
# WAY 1 -> CONNECT AND PROVISION
resource "aws_instance" "whisky_site" {
#  ami           = "ami-04505e74c0741db8d" #-> Hard coded aim
  ami = data.aws_ami.aws-ubuntu.id
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "whisky1"
  security_groups = [aws_security_group.allow_ssh.name]

  provisioner "remote-exec" {
    inline =[
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "echo '<html><head><title>Whisky Team Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Have a &#129347 with grandpa;</span></span></p></body></html>' | sudo tee /var/www/html/index.nginx-debian.html"
    ]

    connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("./whisky1.pem")
    host     = self.public_ip
    }
  }

  tags = {
    name        = "Whiskey first site"
    Service     = "Provision"
  }
}
# WAY 2 -> USING USER DATA
resource "aws_instance" "whisky_site_2" {
  ami                    = data.aws_ami.aws-ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name = "whiskey2"
  user_data = <<-EOF
                #! /bin/bash
                sudo apt-get update
                sudo apt-get install -y nginx
                echo '<html><head><title>Whisky Team Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">DONT DRINK AND DRIVE LEARN DEVOPS INSTEAD</span></span></p></body></html>' | sudo tee /var/www/html/index.nginx-debian.html
  EOF

  tags = {
    name        = "Whiskey second site"
    Service     = "user_data"
  }
}

resource "aws_ebs_volume" "ebs-volume-1" {
  availability_zone = "us-east-1a"
  size              = 20
  type              = "gp2"
  tags = {
    Name = "extra volume data"
  }
}

resource "aws_volume_attachment" "ebs-volume-1-attachment" {
  device_name = "/dev/xvdh"
  volume_id   = aws_ebs_volume.ebs-volume-1.id
  instance_id = aws_instance.whisky_site.id
}


#################################
# OUTPUT
#################################
output "aws_instance" {
  value = aws_instance.whisky_site.id
}

output "ip" {
  value = aws_instance.whisky_site.public_ip
}

output "aws_instance2" {
  value = aws_instance.whisky_site_2.id
}

output "ip2" {
  value = aws_instance.whisky_site_2.public_ip
}
