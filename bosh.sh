#!/bin/bash

sudo apt-get update -y
sudo apt-get  upgrade -y
echo "127.0.0.1 $HOSTNAME" | sudo tee -a   /etc/hosts
echo 'export PS1="\[\033[0;34m\][\u:\h\[\033[0;35m\]:\w]\[\033[0;39m\]\n\[\033[0;33m\]\342\226\210\342\226\210\[\033[0;39m\]"' >> /home/ubuntu/.bashrc
sudo apt-get install -y build-essential zlibc zlib1g-dev ruby ruby-dev openssl libxslt-dev libxml2-dev libssl-dev libreadline6 libreadline6-dev libyaml-dev libsqlite3-dev sqlite3 git tree

curl -LOo ./bosh https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-3.0.1-linux-amd64
chmod +x ./bosh-cli-3.0.1-linux-amd64
sudo mv ./bosh-cli-3.0.1-linux-amd64 /usr/local/bin/bosh
mkdir /home/ubuntu/bosh && cd /home/ubuntu/bosh
git clone https://github.com/cloudfoundry/bosh-deployment

sed -i -e 's/disk_size: 65_536/disk_size: 8192/' -e 's/persistent_disk_pool: disks/#persistent_disk_pool: disks/' bosh-deployment/bosh.yml

sed -i -e 's/instance_type: m4.xlarge/instance_type: t2.micro/' -e 's/size: 25_000/size: 8_000/' bosh-deployment/aws/cpi.yml 

sed -i -e 's/instance_type: m4.large/instance_type: t2.micro/'  -e 's/instance_type: m4.xlarge/instance_type: t2.micro/' -e 's/disk_size: 50_000/disk_size: 10_000/' -e 's/ephemeral_disk: {size: 25_000}/ephemeral_disk: {size: 10_000}/' -e 's/ephemeral_disk: {size: 50_000}/ephemeral_disk: {size: 10_000}/' bosh-deployment/aws/cloud-config.yml 
cd ~/bosh


cat  << EOF > bosh-deployment/aws/cloud-config.yml
azs:
- name: z1
  cloud_properties:
    availability_zone: eu-west-2a
#- name: z2
#  cloud_properties:
#    availability_zone: ((az))
#- name: z3
#  cloud_properties:
#    availability_zone: ((az))

vm_types:
- name: default
  cloud_properties:
    instance_type: t2.micro
    ephemeral_disk: {size: 10_000}
- name: large
  cloud_properties:
    instance_type: t2.micro
    ephemeral_disk: {size: 10_000}

disk_types:
- name: default
  disk_size: 3000
- name: large
  disk_size: 10_000

networks:
- name: aws
  type: dynamic
  subnets:
    - {az: z1, cloud_properties: {subnet: subnet-7572b00f}}
#- name: aws
#  type: manual
#  subnets:
#  - range: ((internal_cidr))
#    gateway: ((internal_gw))
#    azs: [z1, z2, z3]
#    dns: [8.8.8.8]
#    reserved: [((internal_gw))/30]
#    cloud_properties:
#      subnet: ((subnet_id))
#- name: vip
#  type: vip

compilation:
  workers: 1
  reuse_compilation_vms: true
  az: z1
  vm_type: default
  network: aws
EOF

echo "export BOSH_CLIENT=admin" >> /home/ubuntu/.bashrc
echo 'export BOSH_CLIENT_SECRET="$(bosh int /home/ubuntu/bosh/creds.yml --path /admin_password)"' >> /home/ubuntu/.bashrc
echo 'bosh alias-env bosh -e 192.168.0.7 --ca-cert <(bosh int /home/ubuntu/bosh/creds.yml --path /director_ssl/ca)' >> /home/ubuntu/.bashrc
echo 'alias bosh="bosh -e bosh"' >> /home/ubuntu/.bashrc
