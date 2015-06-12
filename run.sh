#!/bin/bash

cat > /etc/yum.repos.d/rdo-buildsys.repo<<- EOM
[cloud7-openstack-kilo-testing]
name=cloud7-openstack-kilo-testing
baseurl=http://cbs.centos.org/repos/cloud7-openstack-kilo-testing/x86_64/os/
enabled=1
gpgcheck=0

[cloud7-openstack-common-testing]
name=cloud7-openstack-common-testing
baseurl=http://cbs.centos.org/repos/cloud7-openstack-common-testing/x86_64/os/
enabled=1
gpgcheck=0

EOM

echo ' --- this test will run with the following rpm content in repos'
yum list
echo ' --- '

yum -y install centos-release-openstack-kilo
yum -y install yum-utils  &&  yum -y install openstack-packstack && packstack --allinone
