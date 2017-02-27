FROM ubuntu:14.04
# Install Ansible
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-add-repository -y ppa:ansible/ansible
RUN apt-get update
RUN apt-get install -y ansible
# Install Ansible hosts
RUN echo "[local]\nlocalhost ansible_connection=local" > /home/ansible/hosts
