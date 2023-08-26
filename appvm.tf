resource "aws_key_pair" "idrsa" {
  key_name   = "byere"
  public_key = file(var.public_key_path)
  tags = {
    CreatedBy = "terraform"
  }
}
data "aws_subnet" "app" {
  filter {
    name   = "tag:Name"
    values = [var.app_subnet_name]
  }

  depends_on = [
    aws_subnet.subnets
  ]
}

resource "aws_instance" "appserver" {
  ami                         = var.ubuntu_ami_id
  associate_public_ip_address = true
  instance_type               = var.app_ec2_size
  key_name                    = aws_key_pair.idrsa.key_name
  vpc_security_group_ids      = [aws_security_group.app.id]
  subnet_id                   = data.aws_subnet.app.id
  // user_data                   = file(var.ansiblescript)
  tags = {
    Name = "appserver"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = aws_instance.appserver.public_ip
  }

}
resource "null_resource" "script" {
  provisioner "file" {
    source      = "nop-playbook.yaml"
    destination = "/tmp/nop-playbook.yaml"
  }
  provisioner "file" {
    source      = "nopcommerce.service"
    destination = "/tmp/nopcommerce.service"
  }
  provisioner "file" {
    source      = "default"
    destination = "/tmp/default"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install software-properties-common -y",
      "sudo add-apt-repository --yes --update ppa:ansible/ansible",
      "sudo apt install ansible -y",
      "ansible-playbook -i hosts /tmp/nop-playbook.yaml"
    ]
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = aws_instance.appserver.public_ip
  }
  triggers = {
    app_script = var.app_script
  }

  depends_on = [
    aws_subnet.subnets,
    aws_instance.appserver
  ]
}