# developer-environment-setup

[![Build Status](https://travis-ci.org/ottenwbe/developer-environment-setup.svg?branch=master)](https://travis-ci.org/ottenwbe/developer-environment-setup)

Ansible playbook to setup Linux developer machines.

## Usage 

On a local Fedora installation where ansible is __not__ installed:

```sh
sudo sh bootstrap_local.sh hosts Fedora
```

On a local Fedora installation where ansible is installed:
```sh
ansible-playbook -i hosts playbook.yml --connection=local
```

## Testing with Vagrant

```sh
cd test/local
sh test.sh
```
