#!/bin/sh

set -ae

TMPFILE=$(mktemp)
trap "rm -f ${TMPFILE}" EXIT

# shellcheck disable=SC2155
export PKR_VAR_client_id=$ARM_CLIENT_ID
export PKR_VAR_client_secret=$ARM_CLIENT_SECRET
export PKR_VAR_tenant_id=$ARM_TENANT_ID
export PKR_VAR_subscription_id=$ARM_SUBSCRIPTION_ID
export PKR_VAR_rg_name=$MANAGED_IMAGE_RG

packer build \
    ${PACKER_ARGS} \
    "devops-agent-azure.pkr.hcl" |
    tee ${TMPFILE}
