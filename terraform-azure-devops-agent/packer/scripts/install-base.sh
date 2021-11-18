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
# sudo apt-key adv --import <<EOF
# -----BEGIN PGP PUBLIC KEY BLOCK-----

# mQINBFNgFa8BEADTL/REB10M+TfiZOtFHqL5LHKkzTMn/O2r5iIqXGhi6iwZazFs
# 9S5g1eU7WMen5Xp9AREs+OvaHx91onPZ7ZiP7VpZ6ZdwWrnVk1Y/HfI59tWxmNYW
# DmKYBGMj4EUpFPSE9EnFj7dm1WdlCvpognCwZQl9D3BseGqN7OLHfwqqmOlbYN9h
# HYkT+CaqOoWDIGMB3UkBlMr0GuujEP8N1gxg7EOcSCsZH5aKtXubdUlVSphfAAwD
# z4MviB39J22sPBnKmaOT3TUTO5vGeKtC9BAvtgA82jY2TtCEjetnfK/qtzj/6j2N
# xVUbHQydwNQVRU92A7334YvCbn3xUUNI0WOscdmfpgCU0Z9Gb2IqDb9cMjgUi8F6
# MG/QY9/CZjX62XrHRPm3aXsCJOVh/PO1sl2A/rvv8AkpJKYyhm6T8OBFptCsA3V4
# Oic7ZyYhqV0u2r4NON+1MoUeuuoeY2tIrbRxe3ffVOxPzrESzSbc8LC2tYaP+wGd
# W0f57/CoDkUzlvpReCUI1Bv5zP4/jhC63Rh6lffvSf2tQLwOsf5ivPhUtwUfOQjg
# v9P8Wc8K7XZpSOMnDZuDe9wuvB/DiH/P5yiTs2RGsbDdRh5iPfwbtf2+IX6h2lNZ
# XiDKt9Gc26uzeJRx/c7+sLunxq6DLIYvrsEipVI9frHIHV6fFTmqMJY6SwARAQAB
# tEdBenVsIFN5c3RlbXMsIEluYy4gKFBhY2thZ2Ugc2lnbmluZyBrZXkuKSA8cGtp
# LXNpZ25pbmdAYXp1bHN5c3RlbXMuY29tPokCOAQTAQIAIgUCU2AVrwIbAwYLCQgH
# AwIGFQgCCQoLBBYCAwECHgECF4AACgkQsZmDYSGb2cnJ8xAAz1V1PJnfOyaRIP2N
# Ho2uRwGdPsA4eFMXb4Z08eGjDMD3b9WW3D0XnCLbJpaZ6klz0W0s2tcYSneTBaSs
# RAqxgJgBZ5ZMXtrrHld/5qFoBbStLZLefmcPhnfvamwHDCTLUex8NIAI1u3e9Rhb
# 5fbH+gpuYpwHX7hz0FOfpn1sxR03UyxU+ey4AdKe9LG3TJVnB0WcgxpobpbqweLH
# yzcEQCNoFV3r1rlE13Y0aE31/9apoEwiYvqAzEmE38TukDLl/Qg8rkR1t0/lok2P
# G6pWqdN7pmoUovBTvDi5YOthcjZcdOTXXn2Yw4RZVF9uhRsVfku1Eg25SnOje3uY
# smtQLME4eESbePdjyV/okCIle66uHZse+7gNyNmWpf01hM+VmAySIAyKa0Ku8AXZ
# MydEcJTebrNfW9uMLsBx3Ts7z/CBfRng6F8louJGlZtlSwddTkZVcb26T20xeo0a
# ZvdFXM2djTi/a5nbBoZQL85AEeV7HaphFLdPrgmMtS8sSZUEVvdaxp7WJsVuF9cO
# Nxsvx40OYTvfco0W41Lm8/sEuQ7YueEVpZxiv5kX56GTU9vXaOOi+8Z7Ee2w6Adz
# 4hrGZkzztggs4tM9geNYnd0XCdZ/ICAskKJABg7biDD1PhEBrqCIqSE3U497vibQ
# Mpkkl/Zpp0BirhGWNyTg8K4JrsQ=
# =d320
# -----END PGP PUBLIC KEY BLOCK-----

# EOF

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
