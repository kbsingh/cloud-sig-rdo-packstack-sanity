#!/bin/bash

echo nameserver 8.8.8.8 > resolv.conf
sudo cp -f resolv.conf /etc/resolv.conf

sudo yum -y install git 
git clone https://git.centos.org/git/sig-core/t_functional
cd t_functional
sudo ./runtests.sh
exit $?
