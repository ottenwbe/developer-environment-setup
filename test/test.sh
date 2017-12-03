#!/usr/bin/env bash

BASEDIR=$(dirname "$0")

pushd .

cd ${BASEDIR}/..

sudo docker build --rm=true --file=test/docker/Dockerfile.fedora27 --tag=fedora27:ansible test/docker
sudo docker run --detach --volume="${PWD}":/home/ansible:ro fedora27:ansible "/sbin/init" > cid27
sudo docker exec --tty "$(cat cid27)" env TERM=xterm ansible-playbook -i /home/ansible/test/docker/test_hosts /home/ansible/site.yml --connection=local --become --extra-vars '{"users": ["testuser1","testuser2"]}' --skip-tags "systemd"
sudo docker stop "$(cat cid27)"

sudo docker build --rm=true --file=test/docker/Dockerfile.fedora26 --tag=fedora26:ansible test/docker
sudo docker run --detach --volume="${PWD}":/home/ansible:ro fedora26:ansible "/sbin/init" > cid26
sudo docker exec --tty "$(cat cid26)" env TERM=xterm ansible-playbook -i /home/ansible/test/docker/test_hosts /home/ansible/site.yml --connection=local --become --extra-vars '{"users": ["testuser1","testuser2"]}' --skip-tags "systemd"
sudo docker stop "$(cat cid26)"

popd