#!/usr/bin/env bash
set -ex

source /etc/environment
env

${RETRIEVE_PARAMETERS}

NAME=$AGENT_NAME_PREFIX-$INSTANCE_NAME

cd /src

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