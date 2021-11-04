#!/usr/bin/env bash
set -ex

#
#if [ -z "${LINUX_AGENT_URL}" ]; then
#  echo "missing mandatory env var: LINUX_AGENT_URL"
#  exit 1
#fi

sudo mkdir -p /src
sudo chown ubuntu /src

LINUX_AGENT_URL="https://vstsagentpackage.azureedge.net/agent/2.194.0/vsts-agent-linux-x64-2.194.0.tar.gz",
DEVOPS_ORG_URL="https://dev.azure.com/EDDI-CRM",
DEVOPS_AGENT_POOL="aws-by-thundercats",
DEVOPS_ORG_TOKEN="TOKEEEEN"

cd /src
wget -c ${LINUX_AGENT_URL} -O - | tar -xz
ls -lah
./config.sh --unattended \
            --url ${DEVOPS_ORG_URL} \
            --auth pat \
            --token ${DEVOPS_ORG_TOKEN} \
            --pool ${DEVOPS_AGENT_POOL} \
            --agent localtestonferdismachine \
            --replace \
            --acceptTeeEula