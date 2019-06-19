#!/usr/bin/env bash

set -uex pipefail

BASEDIR=$(dirname "$0")
FEDORA_VERSION=30

pushd .

cd ${BASEDIR}/..

docker build --rm=true --file=test/docker/Dockerfile.fedora --build-arg "FEDORA_VERSION=${FEDORA_VERSION}" --tag=fedora${FEDORA_VERSION}:ansible test/docker
docker run --detach --volume="${PWD}":/home/ansible:ro fedora${FEDORA_VERSION}:ansible "/sbin/init" > cid
docker exec --tty "$(cat cid)" env TERM=xterm ansible-playbook -i /home/ansible/test/docker/test_hosts /home/ansible/site.yml --connection=local --become --extra-vars '{"users": ["testuser1","testuser2"]}' --skip-tags "systemd"
docker stop "$(cat cid)"
docker rm "$(cat cid)"

popd