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
docker run --name=test-fedora --volume="${PWD}":/home/ansible:ro --rm fedora-ansible:${FEDORA_VERSION} /bin/bash -c 'cp -r /home/ansible /tmp/ansible && chmod 755 /tmp/ansible/bootstrap_local.sh && /tmp/ansible/bootstrap_local.sh "$@"' -- /home/ansible/test/docker/inventory.yml '{"users": [{"username": "testuser1"}, {"username": "testuser2"}], "go_version": "1.17.1.linux-amd64"}' Fedora "${TAGS}" false

popd