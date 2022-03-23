#!/usr/bin/env bash
set -ex

# Mock для
touch variables.auto.tfvars
# Інціалізація terraform
terraform init .

# Інціалізація env ansible та встановлення залежностей
cd ./ansible
python3 -m venv ./venv
source ./venv/bin/activate
pip3 install  -r ./requirements.txt
ansible-galaxy install -r requirements.yml

