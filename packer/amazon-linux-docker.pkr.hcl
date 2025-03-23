packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "amazon_linux" {
  region              = "us-east-1"
  instance_type       = "t2.micro"
  # Find the most recent Amazon Linux 2 AMI
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_username        = "ec2-user"
  ami_name            = "amazon-linux-docker-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.amazon_linux"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install docker -y",
      "sudo service docker start",
      "sudo usermod -aG docker ec2-user",
      "mkdir -p /home/ec2-user/.ssh",
      "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCwI07K+2tpRVvMSGtiCV3exWBle0AxV2Ya0N3j9G3w0OAHGuny0c9yh8M93oONRygJomWobF9e9+ejPNJDio8DsDy0MtxrEYgXfIzM+Il6qBzO1RkWXi9ywGKULFoyRhFQKTXf5Uto184dJrMS3knCMVmqByuzOHuIXdrZeOV3ryEIFrrDRVSSA076B0Kcjtv0YoqWIqoow8FDHrA69DEgiph3C/r0bKl5LQTz/GhhbzfVZxJclP8aOLRSyz0qd+5hZEDOWFbMV2GOdmxioXBfncTh/e1CxXUmpaWTwH1ROvgRZmVpbIiRLGkNHwR1d7z/OXVB0TfNvDGPQfm8uEuzojfuK/ctQjZi/awIAmDHIZeWKRCc8p/FRdfDHMcoFjKuFPAMenaNtW5JYAM9YLc6o8uwizUdgFigWJYqH9qRb0Dokjl9w7h4RPEAlgtnGEARIe0nu66SAmGUSwzhuPR0LUvDlxubk2CL8VzgdMrTgq0lPYEjSP6/9Pad1ut/1viERVYdpfIWgUeYf7QvmCTQ1HfdhXj+CtJp5W2fstGgi2v7JHCkMr673ebcy6sv4XXIl/UWs1naTU5GZBUQHepvDe819MlR9FdVLl0Vd4m35Tk93oIdJohHcq72vuELyTyLOlM13weonvUW0NfN34U7FoABVdnsGACsUL5TXfXxhQ== zhunanshuai@macbookpro.lan' >> /home/ec2-user/.ssh/authorized_keys",
      "sudo chown -R ec2-user:ec2-user /home/ec2-user/.ssh"
    ]
  }
}
