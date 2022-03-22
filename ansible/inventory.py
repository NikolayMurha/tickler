#!/usr/bin/env python3

import argparse
import os
import os.path
import subprocess
import json

inventory = {'all': {'hosts': [], 'vars': {}}}

def arguments_parser():
    base_path = os.path.dirname(__file__)
    parser = argparse.ArgumentParser()
    parser.add_argument('--state', default=base_path + '/terraform.tfstate', help="Path to state file")
    parser.add_argument('--list', action='store_true', help="Output all hosts info, works as inventory script")
    parser.add_argument('--host', action='store_true', help="Output specific host info, works as inventory script")
    parser.add_argument('--use-label', action='store_true', help="Use labels as address")
    parser.add_argument('--use-name', action='store_true', help="Use name as address")
    return parser


def main():
    parser = arguments_parser()
    args = parser.parse_args()
    if os.path.isdir(args.state):
        os.chdir(args.state)
        result = subprocess.run(['terraform', 'state', 'pull'], stdout=subprocess.PIPE)
        data = result.stdout.decode('utf-8')
        data = json.loads(data)
    else:
        with open(args.state) as json_file:
            data = json.load(json_file)

    resources = data['resources']
    if os.getenv('DEBUG'):
        print(json.dumps(resources, indent=4, sort_keys=True))
    for resource in resources:
        if resource['type'] == 'linode_instance':
            for instance in resource['instances']:
                instance = instance['attributes']
                set_hostvars(instance)

                host = instance['label']
                tags = instance['tags']
                for tag in tags:
                    if "group." not in tag or 'all' in tag:
                        continue
                    group = tag.replace('group.', '')
                    add_host_to_group(group, host)
                    add_child_to_group('all', group)
    set_group_var('coreos', 'ansible_user', 'core')
    set_group_var('coreos', 'bin_dir', '/opt/bin')
    set_group_var('coreos', 'ansible_python_interpreter', '/opt/bin/python')
    set_group_var('debian', 'ansible_user', 'root')
    add_child_to_group('k8s-cluster', 'kube-node')
    add_child_to_group('k8s-cluster', 'kube-master')
    add_group('calico-rr')
    print(json.dumps(inventory, indent=4, sort_keys=True))


def set_hostvars(instance):
    host = instance['label']
    set_hostvar(host, 'public_ip', instance['ip_address'])
    set_hostvar(host, 'ansible_host', instance['ip_address'])

    if instance['private_ip']:
        set_hostvar(host, 'ip', instance['private_ip_address'])
        set_hostvar(host, 'access_ip', instance['private_ip_address'])
    else:
        set_hostvar(host, 'ip', instance['ip_address'])
        set_hostvar(host, 'access_ip', instance['ip_address'])

    if 'CoreOS' in instance['disk'][0]['label']:
        add_host_to_group('coreos', host)
    else:
        add_host_to_group('debian', host)


def add_child_to_group(group, child):
    add_group(group, [child])


def add_group(group, children=None):
    if children is None:
        children = []
    inventory.setdefault(group, {'hosts': []})
    if not children or len(children) == 0:
        return

    if 'children' not in inventory[group]:
        inventory[group]['children'] = []
    children = set(inventory[group]['children'] + children)
    inventory[group]['children'] = list(children)


def add_host_to_group(group, host):
    inventory.setdefault(group, {})
    if 'hosts' not in inventory[group]:
        inventory[group]['hosts'] = []
    inventory[group]['hosts'].append(host)
    inventory[group]['hosts'] = list(set(inventory[group]['hosts']))


def set_hostvar(host, var, value):
    inventory.setdefault('_meta', {'hostvars': {}})
    if str(host) not in inventory['_meta']['hostvars']:
        inventory['_meta']['hostvars'][host] = {}
    inventory['_meta']['hostvars'][host][var] = value


def set_group_var(group, var, value):
    add_group(group)
    if 'vars' not in inventory[group]:
        inventory[group]['vars'] = {}
    inventory[group]['vars'][var] = value


if __name__ == '__main__':
    main()

