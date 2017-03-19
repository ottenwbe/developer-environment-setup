# developer-environment-setup

[![Build Status](https://travis-ci.org/ottenwbe/developer-environment-setup.svg?branch=master)](https://travis-ci.org/ottenwbe/developer-environment-setup)

Ansible playbook to setup Linux developer machines.

## Structure

```
.
├── bootstrap_local.sh  // Script to bootstrap the ansible environment before executing the playbook
├── playbook.yml        // Playbook that wraps all tasks
├── ...
├── tasks/              // Tasks to be executed by playbook                      
└── test/               // Test the playbook in vagrant boxes or docker images
    ├── docker/
    └── vagrant/
```

## Usage 

The ```bootstrap_local.sh``` script installs ansible as a prerequisite for executing the playbook.
On a local Fedora installation where ansible is __not__ installed the playbook can be executed as follows:

```bash
sudo sh bootstrap_local.sh hosts Fedora
```

On a local Linux installation where ansible is installed the playbook can be executed as follows:
```bash
ansible-playbook -i hosts playbook.yml --connection=local
```

## Testing 

The playbook can be tested in a Vagrant box or in a Docker container.

### Vagrant

```bash
cd test/vagrant
./test.sh # Executes vagrant up, halt and destroy 
```

### Docker

On a non selinux you can simply pull a docker image, say an Ubuntu image, and execute the playbook in a container:

```bash
sudo docker pull ubuntu:24
sudo docker build --rm=true --file=test/docker/Dockerfile.ubuntu --tag=ubuntu:ansible test/docker
sudo docker run --detach --volume="${PWD}":/home/ansible:ro ubuntu:ansible "/sbin/init" > cid
sudo docker exec --tty "$(cat cid)" env TERM=xterm ansible-playbook -i test/docker/test_hosts playbook.yml --connection=local --become
```

Similarly you can execute the test for a Fedora system when using Dockerfile.fedora and pulling a fedora image.

After the test you can stop the container:
```bash
sudo docker stop "$(cat cid)"
```