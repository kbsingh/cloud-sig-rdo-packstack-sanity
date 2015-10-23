#!/bin/bash

# pre-req's first
systemctl stop NetworkManager
systemctl disable NetworkManager
systemctl restart network

# Get manual payload & init cloud
yum -y install centos-release-openstack-liberty
yum list
yum -y install yum-utils  &&  yum -y install openstack-packstack && packstack --allinone
if [ $? -ne 0 ]; then
  echo 'packstack is now in a happy state'
  exit 1
fi

# Get the CentOS-7 qcow2, import into glance, setup security group, run an instance
. ~/keystonerc_demo
curl -O http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2
glance image-create --name='CentOS7' --container-format=bare --disk-format=qcow2 < CentOS-7-x86_64-GenericCloud.qcow2 
nova secgroup-create gen_sg "generic :22 and icmp"
nova secgroup-add-rule gen_sg icmp 0 255 0.0.0.0/0
nova secgroup-add-rule gen_sg tcp 22 22 0.0.0.0/0
nova keypair-add --pub-key ~/.ssh/id_rsa.pub gen_kp
nova boot --image="CentOS7" --flavor="m1.small" --key_name gen_kp --security-groups gen_sg i1
sleep 5

# get the netns setup and wait for ping to start working
net_id=$(neutron router-list -F id -f value )
IP=$(openstack server list -c Networks -f value --name i1 | cut -f 2 -d'=')
ip netns exec qrouter-${net_id} ssh-keyscan -t ecdsa $IP >> ~/.ssh/known_hosts
ssh_cmd="ip netns exec qrouter-${net_id} ssh centos@${IP}"
# we just do this to make sure the ssh works
$ssh_cmd uname -a
ip netns exec qrouter-${net_id} scp test_script.sh centos@${IP}:
$ssh_cmd bash test_script.sh
exit $?
