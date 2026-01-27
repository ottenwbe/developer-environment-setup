#!/usr/bin/env bash

# Ensure we are in the script directory
cd "$(dirname "$0")"

hostfile=${1:-}
user=${2:-}
system=${3:-Fedora}

set -uex pipefail

if [ -z "${hostfile}" ] || [ -z "${user}" ] ; then
  echo "usage: ./bootstrap_local.sh <path-to-host-file> <user> [<Fedora>]"
  exit 1
fi

echo "== BEGIN BOOTSTRAP =="
echo "== SETUP ${system} =="
if [ "${system}" == "Fedora" ] ; then
	echo "== Ensure Python on Fedora=="
	sudo dnf -y install python3 python3-pip
  echo "== Start ssh service on Fedora=="
	sudo systemctl start sshd
fi

echo "== SETUP VIRTUAL ENVIRONMENT =="
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi
source .venv/bin/activate

echo "== INSTALL ANSIBLE (AND PREREQUISITES)=="
pip install --upgrade pip
pip install -r requirements.txt

ansible-playbook -i "${hostfile}" site.yml --connection=local --extra-vars "{\"users\": [{\"username\": \"${user}\"}]}" --ask-become-pass

echo "== END BOOTSTRAP =="
