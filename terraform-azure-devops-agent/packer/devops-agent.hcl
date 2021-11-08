source "amazon-ebs" "main" {
  ami_name = "main-ami"
}

variable "region" {
  default = ""
}

build {
  provisioner "shell-local" {
    inline = ["echo {region}"]
  }

}

# variable:  "sg_ids" {

# }
# "{{env `SG_IDS`}}",
#   "region": "{{env `AWS_DEFAULT_REGION`}}",
#   "timestamp": "{{env `TIMESTAMP`}}",
#   "vpc_id": "{{env `VPC_ID`}}",
#   "linux_agent_url": "https://vstsagentpackage.azureedge.net/agent/2.194.0/vsts-agent-linux-x64-2.194.0.tar.gz",
#   "devops_org_url": "https://dev.azure.com/EDDI-CRM",
#   "devops_agent_pool": "aws-by-thundercats",
#   "devops_org_token": "{{env `DEVOPS_ORG_TOKEN`}}"
# },
# "builders": [
#   {
#     "type": "amazon-ebs",
#     "ami_name": "az-devops-agent-{{user `artifact_version`}}-{{user `timestamp`}}",
#     "region": "{{user `region`}}",
#     "source_ami_filter": {
#       "most_recent": true,
#       "owners": ["099720109477"],
#       "filters": {
#         "name": "ubuntu/images/hvm-ssd/ubuntu-groovy-20.10-amd64-server-*",
#         "state": "available"
#       }
#     },
#     "vpc_id": "{{user `vpc_id`}}",
#     "subnet_filter": {
#       "filters": {
#         "vpc-id": "{{user `vpc_id`}}",
#         "tag:tier": "public"
#       },
#       "random": true
#     },
#     "temporary_iam_instance_profile_policy_document": {
#       "Version": "2012-10-17",
#       "Statement": [
#         {
#           "Action": ["ssm:GetParameter"],
#           "Effect": "Allow",
#           "Resource": "arn:aws:ssm:*:*:parameter/azure-devops/*"
#         }
#       ]
#     },
#     "security_group_ids": "{{user `sg_ids`}}",
#     "instance_type": "m5.large",
#     "associate_public_ip_address": true,
#     "ssh_username": "ubuntu",
#     "ssh_clear_authorized_keys": true,
#     "encrypt_boot": false,
#     "tags": {
#       "Name": "azure-devops",
#       "service": "azure-devops",
#       "team": "thundercats"
#     },
#     "run_tags": {
#       "Name": "azure-devops",
#       "service": "azure-devops",
#       "team": "thundercats"
#     },
#     "force_deregister": true,
#     "force_delete_snapshot": true
#   }
# ],
# provisioner: [
#   {
#       "type": "shell",
#       "script": "scripts/install-base.sh"
#   },
#   {
#     "type": "file",
#     "source": "scripts/install-agent.sh",
#     "destination": "/var/lib/cloud/scripts/per-instance/install-agent.sh"
#   }
# ]
# }
