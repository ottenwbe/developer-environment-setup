#!/bin/bash
#Note: vagrant init ubuntu/trusty32 
vagrant box update
vagrant up --provider virtualbox
vagrant halt
vagrant destroy -f
