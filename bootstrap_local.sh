#!/usr/bin/env bash

echo "== BEGIN BOOTSTRAP =="

hostfile=$1
user=$2
system=$3

set -uex pipefail

if [ -z "${hostfile}" -o -z "${user}" ] ; then
  echo "usage: ./bootstrap_local.sh <path-to-host-file> <user> [<Fedora>]"
  exit 1
fi

if [ -z "${system}" ] ; then
    system="Fedora"
fi

echo "== SETUP ${system} =="
if [ "${system}" == "Fedora" ] ; then
	echo "== Ensure Python on Fedora=="
	sudo dnf -y install python3 python3-pip
  echo "== Start ssh service on Fedora=="
	sudo systemctl start sshd
fi

echo "== INSTALL ANSIBLE (AND PREREQUISITES)=="
pip3 install -r requirements.txt

ansible-playbook -i hosts site.yml --connection=local --extra-vars "{\"users\": [\"${user}\"]}" --ask-become-pass

echo "== END BOOTSTRAP =="
