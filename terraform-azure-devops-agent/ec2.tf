module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = toset(["one"])

  name = "instance-${each.key}"

  ami                    = data.aws_ami.ubuntu.id #"ami-013f118280322ff68"
  instance_type          = "t2.micro"
  key_name               = "edeka-shared.master"
  monitoring             = true
  vpc_security_group_ids = ["sg-42a2db29"] #["sg-028332960c5053279"]
  subnet_id              = "subnet-a5a689ef"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
