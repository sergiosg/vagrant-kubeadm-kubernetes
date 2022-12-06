#!/bin/bash
#
# Setup for Control Plane (Master) servers

set -euxo pipefail

MASTER_IP="10.0.0.10"
NODENAME=$(hostname -s)

sudo kubeadm config images pull

echo "Preflight Check Passed: Downloaded All Required Images"

sudo kubeadm init --config=/vagrant/scripts/kubeadm-config.yaml --upload-certs | tee kubeadm-init.out

mkdir -p "$HOME"/.kube
sudo cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config
sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config

# Save Configs to shared /Vagrant location

# For Vagrant re-runs, check if there is existing configs in the location and delete it for saving new configuration.

config_path="/vagrant/configs"

if [ -d $config_path ]; then
  rm -f $config_path/*
else
  mkdir -p $config_path
fi

cp -i /etc/kubernetes/admin.conf /vagrant/configs/config
touch /vagrant/configs/join.sh
chmod +x /vagrant/configs/join.sh

kubeadm token create --print-join-command > /vagrant/configs/join.sh

