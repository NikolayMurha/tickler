#!/usr/bin/env bash
set -ex
touch variables.auto.tfvars
terraform init .

cd ./ansible
python3 -m venv ./venv
source ./venv/bin/activate
pip3 install  -r ./requirements.txt
ansible-galaxy install -r requirements.yml

