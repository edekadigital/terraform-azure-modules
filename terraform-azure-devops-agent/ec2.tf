module "ec2_instance" {
  count = local.aws_instance_count

  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 3.0"
  name                   = format("${var.project_name_as_resource_prefix}-aws-instance-%03d", count.index + 1)
  ami                    = var.aws_agent_base_image == "" ? data.aws_ami.ubuntu.id : var.aws_agent_base_image
  instance_type          = var.aws_instance_type
  key_name               = var.aws_ssh_key_name
  monitoring             = true
  vpc_security_group_ids = var.aws_security_group_ids
  subnet_id              = var.aws_subnet_id
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

  tags = var.aws_tags
}

resource "aws_iam_role" "devops_agent" {
  name_prefix        = "${var.project_name_as_resource_prefix}-devops-agent-"
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
  count      = length(var.aws_role_policies)
  role       = aws_iam_role.devops_agent.id
  policy_arn = var.aws_role_policies[count.index]
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
