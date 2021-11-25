## Automation templates for provisioning of Azure Devops agent workers

[WIP]

This repo contains a collection of packer and terraform templates to build images for and deploy Azure Devops agents on AWS and Microsoft Azure Cloud. Follow the below instructions to build and deploy the images. Recent versions of packer and terraform are required.

### Build AWS AMI

An active AWS session needs to be present in the credentials file as per below:
```
[temp]
aws_access_key_id=XXXXXXXXXXXXXXXXXXX
aws_secret_access_key=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
aws_session_token=<SESSION_TOKEN>
region=eu-central-1
```

the following env variables need to be defined:
- `AWS_PROFILE` - with the value of the profile in the credentials file as above
- `PAT_SECRET_ARN` - this needs to be the ARN to a secret in AWS Secretmanager which contains a MS Azure Devops PAT token that has "Manage Pipeline Pools" permissions

change into the packer subdir:
```
cd packer
```

run the below shell-script:
```
bash bin/build-packer-aws-hcl.sh
```

### Build Azure Managed Image

Only SPN auth works for now. The following env variables need to be defined:
- `ARM_CLIENT_ID` - Client ID of the SP account
- `ARM_CLIENT_SECRET` - Password for the above SP account
- `ARM_TENANT_ID` - Tenant ID of the Azure account
- `ARM_SUBSCRIPTION_ID` - Subscription ID that packer will use to build the Managed Image in

change into the packer subdir:
```
cd packer
```
run the below shell-script:
```
bash bin/build-packer-azure-hcl.sh
```
