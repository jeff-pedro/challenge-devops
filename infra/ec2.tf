resource "aws_key_pair" "ssh_key" {
  key_name   = var.key
  public_key = file("${var.key}.pub")
}

resource "aws_launch_template" "launch_template" {
  depends_on = [
    aws_security_group.security_group,
    aws_key_pair.ssh_key
  ]

  name          = "lt-ecs-asg-aluraflix"
  image_id      = "ami-02ca28e7c7b8f8be1"
  instance_type = "t2.micro"

  key_name               = var.key
  vpc_security_group_ids = [aws_security_group.security_group.id]
  iam_instance_profile {
    name = "ecsInstanceRole"
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
      volume_type = "gp3"
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ecs-instance"
    }
  }

  user_data = filebase64("${path.module}/ecs.sh")
}
