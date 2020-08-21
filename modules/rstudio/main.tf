// Building an EC2 machine that will carry the information
// about the connection with the EMR Spark cluster

resource "aws_instance" "rstudio-ec2-instance" {

  ami = "ami-0affd4508a5d2481b"
  instance_type = var.ec2_instance_type

  availability_zone = "${var.region}a"
  subnet_id = var.subnet_id
  associate_public_ip_address = true

  iam_instance_profile = var.ec2_iam_instance_profile

  root_block_device {
    delete_on_termination = true
    volume_size = var.ec2_ebs_size
    volume_type = "gp2"
  }

  key_name = var.key_name
  security_groups = [var.ec2_security_groups]

  tags = {
    Name = "RStudio EC2 instance"
    EMR = var.associated_emr
  }

  connection {
    type        = "ssh"
    user        = "centos"
    private_key = file("~/Documents/aws/${var.key_name}.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 60",
      "mkdir ~/downloads",
      "sudo yum install -y awscli",
      "aws s3 cp s3://${var.name}/scripts/rstudio-installation.sh ~/downloads",
      "sudo bash ~/downloads/rstudio-installation.sh s3://${var.name}"
    ]
  }

}

