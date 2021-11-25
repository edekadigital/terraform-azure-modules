#!/usr/bin/env bash
set -ex

export CURRENT_USER=$(whoami)
echo $CURRENT_USER
cat /etc/passwd

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y full-upgrade
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends apt-transport-https
sudo DEBIAN_FRONTEND=noninteractive sudo apt-get -yq install gnupg curl 
sudo apt-key adv \
  --keyserver hkp://keyserver.ubuntu.com:80 \
  --recv-keys 0xB1998361219BD9C9
curl -O https://cdn.azul.com/zulu/bin/zulu-repo_1.0.0-3_all.deb

# add the zulu key: 0xB1998361219BD9C9
sudo su - -c "curl http://repos.azulsystems.com/RPM-GPG-KEY-azulsystems | apt-key adv --import -"

sudo DEBIAN_FRONTEND=noninteractive sudo apt-get install ./zulu-repo_1.0.0-3_all.deb

sudo apt-get update

sudo DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
  git \
  htop \
  iftop \
  iotop \
  less \
  net-tools \
  python3-pip \
  python3-testresources \
  unzip \
  vim \
  zulu11-jdk \
  docker-compose \
  docker.io \
  azure-cli \
  jq
sudo pip3 install \
  boto3 \
  awscli \
  six \
  --ignore-installed
sudo pip3 install \
  requests \
  --upgrade

sudo usermod -aG docker $CURRENT_USER

sudo ln -fns /usr/share/zoneinfo/Europe/Berlin /etc/localtime
sudo dpkg-reconfigure -f noninteractive tzdata

# Download and "install" nvm
git clone https://github.com/nvm-sh/nvm $HOME/opt/nvm
mkdir -p $HOME/local/nvm
echo "# make nvm available at startup" >> ~/.bashrc
echo "export NVM_DIR=$HOME/local/nvm" >> ~/.bashrc
echo "source $HOME/opt/nvm/nvm.sh" >> ~/.bashrc # this loads nvm
cat ~/.bashrc
source ~/.bashrc

export NVM_DIR=$HOME/local/nvm
source $HOME/opt/nvm/nvm.sh

# install npm versions
nvm install 14
nvm install 16
nvm install 17

# use npm 16 and make default
nvm use 16
nvm alias default 16

npm install --global yarn

sudo DEBIAN_FRONTEND=noninteractive apt-get -y autoremove
sudo systemctl status snap.amazon-ssm-agent.amazon-ssm-agent.service && \
    sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service && \
    sudo systemctl disable ssh.service \
  || echo "amazon-ssm-agent not installed (are we on azure?)"

LINUX_AGENT_URL=https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz

if [ "$(curl $LINUX_AGENT_URL -I 2>/dev/null | head -1 | cut -d' ' -f2)" -eq "200" ]
then
  echo "Agent with version ${AGENT_VERSION} found, dowloading..."
  sudo mkdir -p /src
  sudo chown ubuntu /src
  sudo chgrp ubuntu /src
  cd /src
  wget -c $LINUX_AGENT_URL -O - | tar -xz
  cd -
else
  >&2 echo "Agent with version ${AGENT_VERSION} not found, please check agent_version variable and try again."
  exit 1
fi

sudo rm -f /etc/cron.d/popularity-contest

sudo mv ~/install-agent.sh /var/lib/cloud/scripts/per-instance/install-agent.sh
sudo chmod +x /var/lib/cloud/scripts/per-instance/install-agent.sh
sudo chown root:root /var/lib/cloud/scripts/per-instance/install-agent.sh
