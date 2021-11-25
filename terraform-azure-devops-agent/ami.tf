data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["az-devops-agent-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["553574040935"]
}
