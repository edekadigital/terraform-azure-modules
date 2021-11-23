# resource "aws_secretsmanager_secret" "devops_pat" {
#   name = var.devops_pat_secret_name
# }

# resource "aws_secretsmanager_secret_version" "devops_pat" {
#   secret_id     = aws_secretsmanager_secret.devops_pat.id
#   secret_string = var.devops_pat
# }

module "ec2_instance" {
  count = var.aws_instance_count

  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 3.0"
  name                   = format("instance-%03d", count.index + 1)
  ami                    = var.aws_agent_base_image == "" ? data.aws_ami.ubuntu.id : var.aws_agent_base_image
  instance_type          = "m5.xlarge"
  key_name               = "edeka-shared.master"
  monitoring             = true
  vpc_security_group_ids = ["sg-42a2db29"]
  subnet_id              = "subnet-55d1fe1f"
  iam_instance_profile   = aws_iam_instance_profile.devops_agent.name

  user_data = templatefile("${path.module}/cloud-init.tpl", {
    ENV_VARS = {
      "SECRET_ID"         = var.aws_devops_pat_secret_arn
      "AGENT_NAME_PREFIX" = "${var.agent_name_prefix}-aws"
      "DEVOPS_ORG_URL"    = var.devops_org_url
      "DEVOPS_AGENT_POOL" = var.devops_agent_pool
  } })

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 50
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
    service     = "azure-devops"
    team        = "thundercats"
  }
}

resource "aws_iam_role" "devops_agent" {
  name_prefix        = "devops-agent-"
  assume_role_policy = data.aws_iam_policy_document.devops_agent_assume.json
}

data "aws_iam_policy_document" "devops_agent_assume" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      identifiers = [
        "ec2.amazonaws.com"
      ]
      type = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "devops_agent" {
  role       = aws_iam_role.devops_agent.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "devops_agent" {
  name = "devops-agent-instance-profile"
  role = aws_iam_role.devops_agent.name
}

resource "aws_iam_role_policy" "devops_agent" {
  role   = aws_iam_role.devops_agent.id
  policy = data.aws_iam_policy_document.devops_agent.json
}

data "aws_iam_policy_document" "devops_agent" {
  statement {
    sid    = "DescribeEc2Instance"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "RetrieveSecret"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      var.aws_devops_pat_secret_arn
    ]
  }
}