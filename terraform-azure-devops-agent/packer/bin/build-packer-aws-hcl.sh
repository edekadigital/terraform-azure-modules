#!/bin/sh

set -ae
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
SG_ID=$(aws ec2 create-security-group --group-name "packer-ssh-${TIMESTAMP}" --description "security group for packer" --vpc-id "${VPC_ID}" --output text)
assert_non_zero "${SG_ID}" "SG_ID"
trap "rm -f ${TMPFILE}; aws ec2 delete-security-group --group-id ${SG_ID}" EXIT
aws ec2 authorize-security-group-ingress --group-id "${SG_ID}" --protocol tcp --port 22 --cidr 0.0.0.0/0 --output text
SG_IDS="${SG_ID}"
assert_non_zero "${SG_IDS}" "SG_IDS"
PAT_SECRET_ARN=$(aws secretsmanager list-secrets --filters "Key=name,Values=devops/agents/pat" --query SecretList[].ARN --output text)
assert_non_zero "${PAT_SECRET_ARN}" "PAT_SECRET_ARN"

export PKR_VAR_sg_id=${SG_ID}
export PKR_VAR_vpc_id=${VPC_ID}
export PKR_VAR_devops_org_token_secret_arn=${PAT_SECRET_ARN}
export PKR_VAR_tags=${TAGS}

packer build \
    ${PACKER_ARGS} \
    "devops-agent-aws.pkr.hcl" |
    tee ${TMPFILE}
