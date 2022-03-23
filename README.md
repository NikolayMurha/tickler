# tickler

Terraform + Ansible для швидкого підняття `mhddos_proxy` на хмарних сервісах.
Передбачається, ви вже знайомі з Terraform + Ansible

Корисні посилання:

https://ddosukraine.com.ua

## Налаштування

#### Встановлюємо Terraform

https://learn.hashicorp.com/tutorials/terraform/install-cli

#### Встановлюємо Python

https://realpython.com/installing-python

https://www.python.org/downloads/

#### Ініціалізація `terraform`, `venv` та встановлення `Ansible` із залежностями
                                          
Передбачається використання `venv` в папці `ansible`

```
terraform init .
touch variables.auto.tfvars 
cd ./ansible 
python3 -m venv ./venv
source ./venv/bin/activate
pip3 install  -r ./requirements.txt
ansible-galaxy install -r requirements.yml
```

### Налаштування параметрів інстансів

Деякі коменти є у файлі `variables.tf`

Приклад `variables.auto.tfvars`:

```
# Linode API  Token
linode_token = "...."

# Azure Cli auth 
azure_subscription_id = "....."
azure_tenant_id =  "...."

# API Token Digital Ocean 
do_token = "....." 

authorized_keys = [
  "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAklOUpkDHrfHY17SbrmTIpNLTGK9Tjom/BWDSUGPl+nafzlHDTYW7hdI4yZ5ew18JH4JW9jbhUFrviQzM7xlELEVf4h9lFX5QVkbPppSwg0cda3Pbv7kOdJ/MTyBlWXFCR+HAo3FXRitBqxiX1nKhXpHAZsMciLq8V6RjsNAQwdsdMFvSlVK/7XAt3FaoJoAsncM1Q9x5+3V0Ww68/eIFmb1zuUFljQJKprrX88XypNDvjYNby6vw/Pb0rwert/EnmZ+AW4OZPnTPI89ZPmVMLuayrD2cE86Z/il8b+gw3r3+1nKatmIkjn2so1d01QraTlMqVSsbxNrRFi9wrf+M7Q== schacon@mylaptop.local",
]

azure_vm_count  = 0
linode_vm_count = 0
do_vm_count = 0
```

### Налаштування цілей (ansible):

`ansible/inventory/group_vars/tickler/default.yml`

Посылання на файл з цілями:

`tickler_targets: https://raw.githubusercontent.com/SlavaUkraineSince1991/DDoS-for-all/main/targets/targets.txt`

Кількість палалельних потоків:

`tickler_threads: 1000`

Масив з цілями. Має пріорітет над `tickler_targets`

`tickler_targets_list: []`


