#!/usr/bin/env bash

# Ensure we are in the script directory
cd "$(dirname "$0")"

inventoryfile=${1:-}
extra_vars=${2:-}
system=${3:-Fedora}
tags=${4:-all}
start_sshd=${5:-true}

set -uex pipefail

if [ -z "${inventoryfile}" ] || [ -z "${extra_vars}" ] ; then
  echo "usage: ./bootstrap_local.sh <path-to-host-file> <extra-vars-json> [<Fedora> [<all|tag1,tag2> [<start_sshd>]]]"
  exit 1
fi

echo "== BEGIN BOOTSTRAP =="
echo "== SETUP ${system} =="
if [ "${system}" == "Fedora" ] ; then
	echo "== Ensure Python on Fedora=="
	sudo dnf -y install python3 python3-pip
	if [ "${start_sshd}" == "true" ]; then
		echo "== Start ssh service on Fedora=="
		sudo systemctl start sshd
	fi
fi

echo "== SETUP VIRTUAL ENVIRONMENT =="
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi
source .venv/bin/activate

echo "== INSTALL ANSIBLE (AND PREREQUISITES)=="
pip install --upgrade pip
pip install -r requirements.txt

ansible-playbook -i "${inventoryfile}" site.yml --connection=local --extra-vars "${extra_vars}" --become --tags "${tags}"

echo "== END BOOTSTRAP =="
