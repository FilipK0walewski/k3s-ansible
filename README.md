# k3s-ansible

An Ansible-based automation project for provisioning a lightweight Kubernetes (k3s) cluster across multiple Linux nodes.

## Purpose

This project installs and configures a k3s cluster using repeatable, automated Ansible playbooks. It supports master/agent roles and is designed for home labs, development environments, and small-scale clusters.

## Features

* Automated k3s installation on all nodes
* Separation of server and agent roles
* Role-based structure for maintainability
* SSH-based provisioning
* Customizable cluster configuration through variables

## Requirements

* Ansible ≥ 2.10
* SSH access to all target nodes
* Linux hosts (Ubuntu/Debian/CentOS/AlmaLinux recommended)
* Python installed on the managed nodes
* Public SSH key distributed to each node

## Inventory Structure

Example inventory file (`inventory/hosts.yaml`):

```
[k3s_server]
192.168.1.10

[k3s_agents]
192.168.1.11
192.168.1.12
```

## Usage

1. Install dependencies:

   ```
   pip install ansible
   ```

2. Test connectivity:

   ```
   ansible all -i inventory/hosts.ini -m ping
   ```

3. Deploy the cluster:

   ```
   ansible-playbook -i inventory/hosts.ini site.yml
   ```

## File Structure

```
.
├── ansible.cfg
├── inventory/
│   └── hosts.ini
├── playbooks/
├── roles/
│   └── k3s/
└── site.yml
```

## Customization

Place configuration variables in:

```
group_vars/
  k3s_server.yml
  k3s_agents.yml
```

Use these to configure:

* k3s version
* node tokens
* networking options
* server/agent parameters

## Uninstall

You can remove k3s manually from nodes:

```
/usr/local/bin/k3s-uninstall.sh
```

(Agent nodes use `k3s-agent-uninstall.sh`.)

## License

This project is licensed under the MIT License.
