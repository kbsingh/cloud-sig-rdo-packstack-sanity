#!/bin/bash

sudo yum -y install git 
git clone https://git.centos.org/git/sig-core/t_functional
cd t_functional
sudo ./runtests.sh
exit $?
