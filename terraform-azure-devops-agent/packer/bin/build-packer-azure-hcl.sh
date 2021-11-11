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


# shellcheck disable=SC2155
# shellcheck disable=SC2155
# trap "rm -f ${TMPFILE}; aws ec2 delete-security-group --group-id ${SG_ID}" EXIT

export DEVOPS_ORG_TOKEN=TOKEEEEEN
export PKR_VAR_client_id=$ARM_CLIENT_ID
export PKR_VAR_client_secret=$ARM_CLIENT_SECRET
export PKR_VAR_tenant_id=$ARM_TENANT_ID
export PKR_VAR_subscription_id=$ARM_SUBSCRIPTION_ID
export PKR_VAR_rg_name=crm-shared-rg

packer build \
    ${PACKER_ARGS} \
    "devops-agent-azure.pkr.hcl" |
    tee ${TMPFILE}
