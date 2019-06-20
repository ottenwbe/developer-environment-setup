#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
FEDORA_VERSION=$1

set -uex pipefail

pushd .

cd ${BASEDIR}/..

docker build --file=test/docker/Dockerfile.fedora --build-arg "FEDORA_VERSION=${FEDORA_VERSION}" --tag=fedora-ansible:${FEDORA_VERSION} test/docker
docker run --detach --volume="${PWD}":/home/ansible:ro fedora-ansible:${FEDORA_VERSION} "/sbin/init" > cid
docker exec --tty "$(cat cid)" env TERM=xterm ansible-playbook -i /home/ansible/test/docker/test_hosts /home/ansible/site.yml --connection=local --become --extra-vars '{"users": ["testuser1","testuser2"]}' --skip-tags "systemd, long_running"
docker stop "$(cat cid)"
docker rm "$(cat cid)"

popd