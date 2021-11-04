#!/usr/bin/env bash
set -ex

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y full-upgrade
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends apt-transport-https
sudo DEBIAN_FRONTEND=noninteractive sudo apt-get -yq install gnupg curl 
sudo apt-key adv \
  --keyserver hkp://keyserver.ubuntu.com:80 \
  --recv-keys 0xB1998361219BD9C9
curl -O https://cdn.azul.com/zulu/bin/zulu-repo_1.0.0-3_all.deb

# add the datadog key: A2923DFF56EDA6E76E55E492D3A80E30382E94DE
# add the zulu key: 0xB1998361219BD9C9
sudo apt-key adv --import <<EOF
-----BEGIN PGP PUBLIC KEY BLOCK-----

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
lh9xpuI9M+8ZHCYJ
=VSVF
-----END PGP PUBLIC KEY BLOCK-----
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBFNgFa8BEADTL/REB10M+TfiZOtFHqL5LHKkzTMn/O2r5iIqXGhi6iwZazFs
9S5g1eU7WMen5Xp9AREs+OvaHx91onPZ7ZiP7VpZ6ZdwWrnVk1Y/HfI59tWxmNYW
DmKYBGMj4EUpFPSE9EnFj7dm1WdlCvpognCwZQl9D3BseGqN7OLHfwqqmOlbYN9h
HYkT+CaqOoWDIGMB3UkBlMr0GuujEP8N1gxg7EOcSCsZH5aKtXubdUlVSphfAAwD
z4MviB39J22sPBnKmaOT3TUTO5vGeKtC9BAvtgA82jY2TtCEjetnfK/qtzj/6j2N
xVUbHQydwNQVRU92A7334YvCbn3xUUNI0WOscdmfpgCU0Z9Gb2IqDb9cMjgUi8F6
MG/QY9/CZjX62XrHRPm3aXsCJOVh/PO1sl2A/rvv8AkpJKYyhm6T8OBFptCsA3V4
Oic7ZyYhqV0u2r4NON+1MoUeuuoeY2tIrbRxe3ffVOxPzrESzSbc8LC2tYaP+wGd
W0f57/CoDkUzlvpReCUI1Bv5zP4/jhC63Rh6lffvSf2tQLwOsf5ivPhUtwUfOQjg
v9P8Wc8K7XZpSOMnDZuDe9wuvB/DiH/P5yiTs2RGsbDdRh5iPfwbtf2+IX6h2lNZ
XiDKt9Gc26uzeJRx/c7+sLunxq6DLIYvrsEipVI9frHIHV6fFTmqMJY6SwARAQAB
tEdBenVsIFN5c3RlbXMsIEluYy4gKFBhY2thZ2Ugc2lnbmluZyBrZXkuKSA8cGtp
LXNpZ25pbmdAYXp1bHN5c3RlbXMuY29tPokCOAQTAQIAIgUCU2AVrwIbAwYLCQgH
AwIGFQgCCQoLBBYCAwECHgECF4AACgkQsZmDYSGb2cnJ8xAAz1V1PJnfOyaRIP2N
Ho2uRwGdPsA4eFMXb4Z08eGjDMD3b9WW3D0XnCLbJpaZ6klz0W0s2tcYSneTBaSs
RAqxgJgBZ5ZMXtrrHld/5qFoBbStLZLefmcPhnfvamwHDCTLUex8NIAI1u3e9Rhb
5fbH+gpuYpwHX7hz0FOfpn1sxR03UyxU+ey4AdKe9LG3TJVnB0WcgxpobpbqweLH
yzcEQCNoFV3r1rlE13Y0aE31/9apoEwiYvqAzEmE38TukDLl/Qg8rkR1t0/lok2P
G6pWqdN7pmoUovBTvDi5YOthcjZcdOTXXn2Yw4RZVF9uhRsVfku1Eg25SnOje3uY
smtQLME4eESbePdjyV/okCIle66uHZse+7gNyNmWpf01hM+VmAySIAyKa0Ku8AXZ
MydEcJTebrNfW9uMLsBx3Ts7z/CBfRng6F8louJGlZtlSwddTkZVcb26T20xeo0a
ZvdFXM2djTi/a5nbBoZQL85AEeV7HaphFLdPrgmMtS8sSZUEVvdaxp7WJsVuF9cO
Nxsvx40OYTvfco0W41Lm8/sEuQ7YueEVpZxiv5kX56GTU9vXaOOi+8Z7Ee2w6Adz
4hrGZkzztggs4tM9geNYnd0XCdZ/ICAskKJABg7biDD1PhEBrqCIqSE3U497vibQ
Mpkkl/Zpp0BirhGWNyTg8K4JrsQ=
=d320
-----END PGP PUBLIC KEY BLOCK-----

EOF

echo 'deb https://apt.datadoghq.com/ stable 6' | sudo tee /etc/apt/sources.list.d/datadog.list
sudo DEBIAN_FRONTEND=noninteractive sudo apt-get install ./zulu-repo_1.0.0-3_all.deb

sudo apt-get update

sudo DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
  datadog-agent \
  git \
  htop \
  iftop \
  iotop \
  less \
  net-tools \
  python3-pip \
  unzip \
  vim \
  zulu11-jdk
sudo pip3 install \
  boto3 \
  awscli
sudo gpasswd -a dd-agent adm

sudo ln -fns /usr/share/zoneinfo/Europe/Berlin /etc/localtime
sudo dpkg-reconfigure -f noninteractive tzdata

sudo DEBIAN_FRONTEND=noninteractive apt-get -y autoremove
sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
sudo systemctl disable ssh.service

sudo rm -f /etc/cron.d/popularity-contest