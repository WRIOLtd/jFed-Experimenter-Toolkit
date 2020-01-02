#!/bin/bash

#make sure this folder is writable to all
chmod 777 .

#install dependencies
apt-get update
apt-get install python-dev libffi-dev python-pip python-openssl -y

#install ansible
pip install --upgrade pyOpenSSL markupsafe setuptools ansible

touch /tmp/ansible-install-finished