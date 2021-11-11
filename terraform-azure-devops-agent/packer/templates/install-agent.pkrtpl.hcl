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

${RETRIEVE_PARAMETERS}

LINUX_AGENT_URL="https://vstsagentpackage.azureedge.net/agent/2.194.0/vsts-agent-linux-x64-2.194.0.tar.gz"
DEVOPS_ORG_URL="https://dev.azure.com/EDDI-CRM"
DEVOPS_AGENT_POOL="aws-by-thundercats"
NAME=best-devops-agent-ever-$INSTANCE_NAME

cd /src
# Download and extract the agent, change ownership to ubuntu user
wget -c $LINUX_AGENT_URL -O - | tar -xz
chown -R ubuntu .
chgrp -R ubuntu .


# Configure the agent (must be done as not-root and need to source nvm to detect npm)
su ubuntu -c "
        export NVM_DIR=/home/ubuntu/local/nvm
        source /home/ubuntu/opt/nvm/nvm.sh
        ./config.sh --unattended \
            --url $DEVOPS_ORG_URL \
            --auth pat \
            --token $DEVOPS_ORG_TOKEN \
            --pool $DEVOPS_AGENT_POOL \
            --agent $NAME \
            --replace"

# Install and start service as ubuntu must be done as super user - crazy, I know
su ubuntu -c "sudo ./svc.sh install"
su ubuntu -c "sudo ./svc.sh start"

# remove yourself after running (this contains a secret)
rm /var/lib/cloud/scripts/per-instance/install-agent.sh