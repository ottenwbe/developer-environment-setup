#!/bin/bash

set -e

echo "== BEGIN BOOTSTRAP =="

hostfile=$1
user=$2
system=$3

if [ -z "${hostfile}" ] ; then
  echo "usage: ./bootstrap_local.sh <path-to-host-file> <user> [<Fedora>]"
  exit 1
fi

if [ -z "${user}" ]; then
    echo "usage: ./bootstrap_local.sh <path-to-host-file> <user> [<Fedora>]"
    exit 1
fi

if [ -z "${system}" ] ; then
    system="Fedora"
fi

if [ "${system}" == "Ubuntu" ] ; then
	echo "Ubuntu is no longer supported"
    exit 1
fi

echo "== SETUP ${system} =="
if [ "${system}" == "Fedora" ] ; then
	echo "== Ensure Python on Fedora=="
	sudo dnf -y install python2 python2-dnf
	sudo service sshd start
fi

echo "== INSTALL ANSIBLE =="
pip install markupsafe
pip install ansible

ansible-playbook -i hosts site.yml --connection=local --extra-vars "user=${user}" --ask-become-pass

echo "== END BOOTSTRAP =="
