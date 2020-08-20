// Building an EC2 machine that will carry the information
// about the connection with the EMR Spark cluster

resource "aws_instance" "rstudio-ec2-instance" {

  ami = "ami-0affd4508a5d2481b"
  instance_type = var.ec2_instance_type

  availability_zone = "${var.region}a"
  subnet_id = var.subnet_id
  associate_public_ip_address = true

  iam_instance_profile = var.ec2_iam_instance_profile

  ebs_block_device {
    device_name = "rstudio-ec2-ebs"
    volume_size = var.ec2_ebs_size
    volume_type = "gp2"
    delete_on_termination = true
  }

  key_name = var.key_name
  security_groups = [var.ec2_security_groups]

  tags = {
    Name = "RStudio EC2 instance"
    EMR = var.associated_emr
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir /downloads",
      "aws s3 cp s3://${var.name}/scripts/rstudio-installation.sh /downloads",
      "sudo bash /downloads/rstudio-installation.sh s3://${var.name}"
    ]
  }

}
