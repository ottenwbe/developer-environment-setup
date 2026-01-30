# developer-environment-setup

[![Test Developer Environment Setup](https://github.com/ottenwbe/developer-environment-setup/actions/workflows/main.yml/badge.svg)](https://github.com/ottenwbe/developer-environment-setup/actions/workflows/main.yml)

This ansible playbook is used by me to automate the setup of my Linux developer machines. 
If you frequently reinstall your system, you know why these scripts were created.
Therefore, this repository will be updated whenever I setup a new machine (commits to master).

## Supported Linux Distributions

Right now the only tested Distributions are:
* Fedora 43

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
│   ├── vscode          // Installation of Visual Studio Code
│   ├── ansible         // Installation of Ansible and linting tools
│   ├── cpp             // Everything needed for C(pp) development
│   ├── go              // Everything needed for Golang development
│   ├── java            // Everything needed for Java development
│   ├── kubernetes      // Everything needed for Kubernetes development (minikube, helm, ...)
│   ├── python          // Everything needed for Python development
│   └── ruby            // Everything needed for Ruby development       
│   └── virtualization  // Virtualization tools (VirtualBox, Vagrant)
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
sh bootstrap_local.sh inventory.yml <your user> Fedora
```

On a local Linux installation where ansible is installed the playbook can be executed as follows:
```bash
ansible-playbook -i inventory.yml site.yml --connection=local --extra-vars '{"users": [{"username": "your user", "git_name": "Your Name", "git_email": "email@example.com"}]}' --ask-become-pass
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
docker build --file=test/docker/Dockerfile.fedora --build-arg "FEDORA_VERSION=33" --tag=fedora33:ansible test/docker
docker run --name=test-fedora --volume="${PWD}":/home/ansible:ro fedora33:ansible ansible-playbook -i /home/ansible/test/docker/inventory.yml /home/ansible site.yml --connection=local --become --extra-vars '{"users": [{"username": "testuser1"}, {"username": "testuser2"}], "go_version": "1.17.2.linux-amd64"}' --skip-tags "systemd"
```

or simply use the test scripts

```bash
sh test/test.sh 43 all
```

__Note__: We skip everything related to systemd, since systemd is not monitoring our services in the container. 

After the test has finished you can stop the container and remove it:
```bash
docker rm test-fedora
```

## Note

I created this project for the purpose of educating myself and personal use. If you are interested in the outcome, feel free to contribute; this work is published under the MIT license.