terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "3.56.0"
        }
    }
}

provider "aws" {
    region = "us-west-2"
}

resource "aws_instance" "example" {
    ami           = "ami-0c94855ba95c71c99" // Red Hat Enterprise Linux 8 (HVM), SSD Volume Type
    instance_type = "t2.micro"

    tags = {
        Name = "example-instance"
    }
}

resource "aws_security_group" "web_server_sg" {
    name        = "web-server-sg"
    description = "Security group for web server"
    
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.example.public_ip}, playbook.yml"
}

provisioner "remote-exec" {
    inline = [
        "sudo yum install -y httpd",
        "sudo systemctl start httpd",
        "sudo systemctl enable httpd"
    ]

}