#!/bin/bash


# install wget
sudo apt install -y wget

# install curl
sudo apt install -y curl

# install python
sudo apt update
sudo apt install -y software-properties-common
sudo apt install -y python3 python3-pip
python3 --version

# install docker (Ubuntu 22.04+ / 24.04 method using signed keyring)
sudo apt-get remove -y docker docker-engine docker.io containerd runc docker-compose docker-compose-v2 2>/dev/null || true
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $(whoami)