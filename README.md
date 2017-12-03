# developer-environment-setup

[![Build Status](https://travis-ci.org/ottenwbe/developer-environment-setup.svg?branch=master)](https://travis-ci.org/ottenwbe/developer-environment-setup)

This ansible playbook is used by me to automate the setup of my Linux developer machines. Therefore, this repository will be updated whenever I setup a new machine (commits to master).

## Supported Linux Distributions

Right now the only supported Distribution is:
* Fedora (26,27)

Formerly supported:
* Ubuntu

## Structure

```
.
├── bootstrap_local.sh  // Script to bootstrap the ansible environment before executing the playbook
├── site.yml            // Playbook that wraps all tasks, roles, ...
├── ... 
├── roles/              // Roles to be executed by the playbook
│   ├── common          // Installation of common tools, external repos (rpm-fusion...), etc. 
│   ├── user            // Creation of users
│   ├── zsh             // Installation of zsh for each user
│   ├── cpp             // Everything needed for C(pp) development
│   ├── go              // Everything needed for Golang development
│   ├── java            // Everything needed for Java development
│   ├── python          // Everything needed for Python development
│   └── ruby            // Everything needed for Ruby development       
└── test/               // Test the playbook in docker images
    └── docker/
```

## Usage 

First of all, clone this repository.

```
    git clone https://github.com/ottenwbe/developer-environment-setup.git
```

The ```bootstrap_local.sh``` script installs ansible as a prerequisite for executing the playbook.
On a local Fedora installation where ansible is __not__ installed the playbook can be executed as follows:

```bash
sh bootstrap_local.sh hosts <your user> Fedora
```

On a local Linux installation where ansible is installed the playbook can be executed as follows:
```bash
ansible-playbook -i hosts site.yml --connection=local --extra-vars '{"users": ["your user"]}' --ask-become-pass
```

## Testing 

The playbook can be tested in a Docker container---more or less.

### Docker


__NOTE__: On an SELinux, i.e., Fedora, first execute the following command in the root directory of the project.

```bash
chcon -Rt svirt_sandbox_file_t "${PWD}"
```

On a non SELinux you can simply build a docker image and execute the playbook in a container. Replace one of the 'testuser's' with a username that suits you and run the following commands:

```bash
sudo docker build --rm=true --file=test/docker/Dockerfile.fedora27 --tag=fedora27:ansible test/docker
sudo docker run --detach --volume="${PWD}":/home/ansible:ro fedora27:ansible "/sbin/init" > cid
sudo docker exec --tty "$(cat cid)" env TERM=xterm ansible-playbook -i /home/ansible/test/docker/test_hosts /home/ansible/site.yml --connection=local --become --extra-vars '{"users": ["testuser1","testuser2"]}' --skip-tags "systemd"
```

__Note__: We skip everything related to systemd, since systemd is not monitoring our services in the container.  

After the test has finished you can stop the container:
```bash
sudo docker stop "$(cat cid)"
```

