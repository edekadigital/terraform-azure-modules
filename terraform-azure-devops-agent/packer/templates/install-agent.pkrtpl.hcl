#!/usr/bin/env bash
set -ex

#
#if [ -z "$LINUX_AGENT_URL" ]; then
#  echo "missing mandatory env var: LINUX_AGENT_URL"
#  exit 1
#fi

mkdir -p /src
chown ubuntu /src
chgrp ubuntu /src

LINUX_AGENT_URL="https://vstsagentpackage.azureedge.net/agent/2.194.0/vsts-agent-linux-x64-2.194.0.tar.gz"
DEVOPS_ORG_URL="https://dev.azure.com/EDDI-CRM"
DEVOPS_AGENT_POOL="aws-by-thundercats"
DEVOPS_ORG_TOKEN="${DEVOPS_ORG_TOKEN}"
NAME=best-devops-agent-$(uuidgen)

cd /src
# Download and extract the agent, change ownership to ubuntu user
wget -c $LINUX_AGENT_URL -O - | tar -xz
chown -R ubuntu .
chgrp -R ubuntu .

# Configure the agent
su ubuntu -- ./config.sh --unattended \
            --url $DEVOPS_ORG_URL \
            --auth pat \
            --token $DEVOPS_ORG_TOKEN \
            --pool $DEVOPS_AGENT_POOL \
            --agent $NAME \
            --replace \

# Install and start service
./svc.sh install
./svc.sh start

# remove yourself after running (this contains a secret)
rm /var/lib/cloud/scripts/per-instance/install-agent.sh