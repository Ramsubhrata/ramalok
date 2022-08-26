resource "aws_autoscaling_group" "example" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1

  launch_template {
    id      = aws_launch_template.example.id
    version = aws_launch_template.example.latest_version
  }

  tag {
    key                 = "Key"
    value               = "Value"
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }
}

data "aws_ami" "example" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "example" {
  image_id      = data.aws_ami.example.id
  instance_type = "t3.nano"
}




variable "extra_tags" {
  default = [
    {
      key                 = "Foo"
      value               = "Bar"
      propagate_at_launch = true
    },
    {
      key                 = "Baz"
      value               = "Bam"
      propagate_at_launch = true
    },
  ]
}

resource "aws_autoscaling_group" "bar" {
  name                 = "foobar3-terraform-test"
  max_size             = 5
  min_size             = 2
  launch_configuration = aws_launch_configuration.foobar.name
  vpc_zone_identifier  = [aws_subnet.example1.id, aws_subnet.example2.id]

  tags = concat(
    [
      {
        "key"                 = "interpolation1"
        "value"               = "value3"
        "propagate_at_launch" = true
      },
      {
        "key"                 = "interpolation2"
        "value"               = "value4"
        "propagate_at_launch" = true
      },
    ],
    var.extra_tags,
  )
}
