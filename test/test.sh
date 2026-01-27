#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
FEDORA_VERSION=$1
TAGS=${2:-all}

set -uex pipefail

cleanup() {
  docker rm -f test-fedora || true
}

trap cleanup EXIT

pushd .

cd ${BASEDIR}/..

cleanup

docker build --file=test/docker/Dockerfile.fedora --build-arg "FEDORA_VERSION=${FEDORA_VERSION}" --tag=fedora-ansible:${FEDORA_VERSION} test/docker
docker run --name=test-fedora --volume="${PWD}":/home/ansible:ro fedora-ansible:${FEDORA_VERSION} ansible-playbook -i /home/ansible/test/docker/inventory.yml /home/ansible/site.yml --connection=local --become --extra-vars '{"users": [{"username": "testuser1"}, {"username": "testuser2"}], "go_version": "1.17.1.linux-amd64"}' --tags "${TAGS}"

popd