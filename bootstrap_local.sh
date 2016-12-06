#!/bin/bash

set -e

echo "== BEGIN BOOTSTRAP =="

hostfile=$1
system=$2

if [ -z "${hostfile}" ] ; then
  echo "usage: ./build.sh <path-to-host-file> [<Fedora|Ubuntu>]"
  exit 1
fi

echo "== SETUP ${system} =="
if [ "${system}" == "Fedora" ] ; then
	echo "== Ensure Python =="
	dnf -y install python2 python2-dnf
	service sshd start	
fi

if [ "${system}" == "Ubuntu" ] ; then
	echo "== Ensure Python =="
    apt-get install -y python python-pip python-apt python-dev build-essential libssl-dev libffi-dev python-dev 	
fi

echo "== INSTALL ANSIBLE =="
pip install markupsafe
pip install ansible


ansible-playbook -i ${hostfile} playbook.yml --connection=local 

echo "== END BOOTSTRAP =="
