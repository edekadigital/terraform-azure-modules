#!/bin/bash
set -ae

assert_non_zero() {
  if [ -z "${1}" ]; then
    echo "${2} is empty!"
    exit 1
  fi
}
# shellcheck disable=SC2155
VPC_ID=$(aws ec2 describe-vpcs \
  --query 'Vpcs[0].VpcId' \
  --output text)
assert_non_zero "${VPC_ID}" "VPC_ID"
# shellcheck disable=SC2155
SG_ID=$(aws ec2 create-security-group --group-name "packer-ssh" --description "security group for packer builds" --vpc-id "${VPC_ID}" --output text)
assert_non_zero "${SG_ID}" "SG_ID"
aws ec2 authorize-security-group-ingress --group-id "${SG_ID}" --protocol tcp --port 22 --cidr 0.0.0.0/0 --output text

echo "successfully created security group for packer with id: $SG_ID"