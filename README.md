# developer-environment-setup

[![Test Developer Environment Setup](https://github.com/ottenwbe/developer-environment-setup/actions/workflows/main.yml/badge.svg)](https://github.com/ottenwbe/developer-environment-setup/actions/workflows/main.yml)
[![Ansible](https://img.shields.io/badge/Ansible-2.15+-EE0000?style=flat&logo=ansible)](https://www.ansible.com/)

This ansible playbook is used by me to automate the setup of my developer machines on both Linux and macOS. 
If you frequently reinstall your system, you know why these scripts were created.
Therefore, this repository will be updated whenever I setup a new machine (commits to master).

## Supported Platforms

Currently tested and supported:
* Fedora 43 (Linux)
* macOS (Tahoe)

## Structure

```
.
├── bootstrap_local.sh  // Script to bootstrap the ansible environment (Linux only)
├── site-linux.yml      // Playbook for Fedora/Linux setup
├── site-mac.yml        // Playbook for macOS setup
├── inventory.local.yml // Local inventory (not versioned, add to .gitignore)
├── ... 
├── roles/              // Roles to be executed by the playbook
│   ├── common          // Installation of common tools, external repos (rpm-fusion...), etc. (Linux only)
│   ├── user            // Creation of users (cross-platform)
│   ├── homebrew        // Package manager setup (macOS only)
│   ├── zsh             // Installation of zsh for each user (cross-platform)
│   ├── vscode          // Installation of Visual Studio Code (cross-platform)
│   ├── ansible         // Installation of Ansible and linting tools (cross-platform)
│   ├── cpp             // Everything needed for C(pp) development (cross-platform)
│   ├── go              // Everything needed for Golang development (cross-platform)
│   ├── java            // Everything needed for Java development (cross-platform)
│   ├── kubernetes      // Everything needed for Kubernetes development (cross-platform)
│   ├── python          // Everything needed for Python development (cross-platform)
│   ├── ruby            // Everything needed for Ruby development (cross-platform)
│   ├── virtualization  // Virtualization tools (cross-platform)
│   ├── intellij        // Installation of IntelliJ IDEA (cross-platform)
│   ├── system          // System configuration (Linux only)
│   └── ai              // AI tools (Ollama, PyTorch, Jupyter) (cross-platform)
└── test/               // Test the playbook in docker images
    └── docker/
```

## Usage 

First of all, clone this repository.

```
git clone https://github.com/ottenwbe/developer-environment-setup.git
```

## Inventory Files

Three inventory files are available:

- **`inventory.example.yml`** - Generic example showing supported OS groups and structure
- **`inventory.localhost.yml`** - Local Fedora machine with `127.0.0.1` for testing (not versioned)
- **`inventory.local.yml`** - For SSH connections to remote machines (not versioned, add to .gitignore)

## Quick Start

### For Local Fedora Testing

Use `inventory.localhost.yml` with the bootstrap script:

```bash
sh bootstrap_local.sh inventory.localhost.yml @vars.json
```

This script will install Python, Ansible, and run the Fedora playbook locally.

### For Local macOS

On macOS, ensure Ansible is installed, then run:

```bash
ansible-playbook -i inventory.localhost.yml site-mac.yml --extra-vars @vars.json --ask-become-pass
```

### For Remote Machines (SSH)

Create `inventory.local.yml` (not versioned) with your remote hosts:

```yaml
all:
  children:
    Fedora:
      hosts:
        fedora-dev:
          ansible_user: your_username
          # Optional: add ansible_host if hostname doesn't resolve
          # ansible_host: 192.168.1.100
    MacOS:
      hosts:
        macos-dev:
          ansible_user: your_username
```

Then run the appropriate playbook:

```bash
# For Fedora machines
ansible-playbook -i inventory.local.yml site-linux.yml --extra-vars @vars.json --ask-become-pass

# For macOS machines
ansible-playbook -i inventory.local.yml site-mac.yml --extra-vars @vars.json --ask-become-pass
```

## Configuration

Create a `vars.json` file to customize your setup (e.g., users, git config, or specific tool versions):

```json
 {
  "users": [
    {
      "username": "youruser",
      "git_name": "Your Name",
      "git_email": "email@example.com"
    }
  ]
}
```

For both Fedora and macOS machines accessible over SSH, create an `inventory.local.yml` file (not versioned):

```yaml
all:
  children:
    Fedora:
      hosts:
        fedora-dev:
          ansible_user: your_username
    MacOS:
      hosts:
        macos-dev:
          ansible_user: your_username
```

Then run the appropriate playbook:

```bash
# For Fedora machines
ansible-playbook -i inventory.local.yml site-linux.yml --extra-vars '{"users": [{"username": "your user", "git_name": "Your Name", "git_email": "email@example.com"}]}' --ask-become-pass

# For macOS machines
ansible-playbook -i inventory.local.yml site-mac.yml --extra-vars '{"users": [{"username": "your user", "git_name": "Your Name", "git_email": "email@example.com"}]}' --ask-become-pass
```

Note: The [git config](https://git-scm.com/docs/git-config) is optionally updated as well for the user.

## Tags 

The playbooks use tags to allow running specific parts of the setup. 

Available tags: 
* system: Runs all system setup roles (user, homebrew/common, zsh, vscode, ansible, system) 
* dev: Runs all development environment roles (go, java, ruby, cpp, python, kubernetes, virtualization, intellij, ai) 
* user: User creation and configuration 
* homebrew: Homebrew package manager setup (macOS only)
* zsh: ZSH shell setup 
* vscode: Visual Studio Code installation 
* ansible: Ansible installation 
* common: Common tools and repositories (Linux only)
* go: Go development environment 
* java: Java development environment 
* ruby: Ruby development environment 
* cpp: C++ development environment 
* python: Python development environment 
* kubernetes: Kubernetes tools (Minikube, Helm, etc.) 
* virtualization: Virtualization tools (VirtualBox, Vagrant) 
* intellij: IntelliJ IDEA installation
* ai: AI tools (Ollama, PyTorch, Jupyter)

To run only specific tags: 
```bash 
# For Fedora
ansible-playbook -i inventory.local.yml site-linux.yml --tags "tag1,tag2" 

# For macOS
ansible-playbook -i inventory.local.yml site-mac.yml --tags "tag1,tag2" 
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
docker build --file=test/docker/Dockerfile.fedora --build-arg "FEDORA_VERSION=43" --tag=fedora43:ansible test/docker
docker run --name=test-fedora --rm --volume="${PWD}":/home/ansible:ro fedora43:ansible ansible-playbook -i /home/ansible/test/docker/inventory.yml /home/ansible/site-linux.yml --connection=local --become --extra-vars '{"users": [{"username": "testuser1"}, {"username": "testuser2"}]}' --skip-tags "common"
```

or simply use the test scripts

```bash
# Test Fedora playbook
sh test/test.sh 43 all
```

__Note__: We skip everything related to systemd, since systemd is not monitoring our services in the container. 

After the test has finished you can stop the container and remove it:
```bash
docker rm test-fedora
```

## Note

I created this project for the purpose of educating myself and personal use. If you are interested in the outcome, feel free to contribute; this work is published under the MIT license.