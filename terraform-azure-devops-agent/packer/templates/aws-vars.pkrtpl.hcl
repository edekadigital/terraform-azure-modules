export AWS_CREDENTIAL_SOURCE=Ec2InstanceMetadata
export AWS_DEFAULT_REGION=eu-central-1
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_NAME=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output text)
DEVOPS_ORG_TOKEN=$(aws secretsmanager get-secret-value --secret-id ${SECRET_ID} --query SecretString --output text)
