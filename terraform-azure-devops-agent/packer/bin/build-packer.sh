#!/bin/sh

set -ae
fetch_secretsmanager_value() {
    aws secretsmanager get-secret-value \
      --secret-id "${1}" \
      --query SecretString \
      --output text
}
assert_non_zero() {
  if [ -z "${1}" ]; then
    echo "${2} is empty!"
    exit 1
  fi
}


TMPFILE=$(mktemp)
trap "rm -f ${TMPFILE}" EXIT

TIMESTAMP=$(date +%Y%m%d%H%M)
AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-eu-central-1}
PACKER_ARGS=""
if [ -n "${CODEBUILD_BUILD_NUMBER}" ]; then
  . ${CODEBUILD_SRC_DIR}/bin/assume-role.sh "${TARGET_ROLE}"
  PACKER_ARGS="${PACKER_ARGS} -color=false"
else
  AWS_PROFILE=${AWS_PROFILE:-dpp-shared-administrator}
fi

# shellcheck disable=SC2155
VPC_ID=$(aws ec2 describe-vpcs \
  --query 'Vpcs[0].VpcId' \
  --output text)
assert_non_zero "${VPC_ID}" "VPC_ID"
# shellcheck disable=SC2155
DD_API_KEY=$(fetch_secretsmanager_value arn:aws:secretsmanager:eu-central-1:553574040935:secret:datadog/apikey-TUu0ml)
assert_non_zero "${DD_API_KEY}" "DD_API_KEY"
SG_ID=$(aws ec2 create-security-group --group-name "packer-ssh-${TIMESTAMP}" --description "security group for packer" --vpc-id "${VPC_ID}" --output text)
assert_non_zero "${SG_ID}" "SG_ID"
trap "rm -f ${TMPFILE}; aws ec2 delete-security-group --group-id ${SG_ID}" EXIT
aws ec2 authorize-security-group-ingress --group-id "${SG_ID}" --protocol tcp --port 22 --cidr 0.0.0.0/0 --output text
#SG_IDS="$(aws ec2 describe-security-groups --filters Name=tag:Name,Values=webserver-reference,webserver_ref --query SecurityGroups[].GroupId --output text | tr '[:blank:]' ','),${SG_ID}"
SG_IDS="${SG_ID}"
assert_non_zero "${SG_IDS}" "SG_IDS"

export DEVOPS_ORG_TOKEN=TOKEEEEEN

packer build \
    ${PACKER_ARGS} \
    "devops-agent.json" |
    tee ${TMPFILE}
