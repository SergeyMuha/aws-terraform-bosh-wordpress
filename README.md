# AWS-Terraform-bosh-wordpress
##### EU-WEST-2a
Create aws infrasctructure and deploy bosh director with ubuntu stemcell


Requirements:
AWS-cli with configured AWS Access Key ID and AWS Secret Access Key -- use https://docs.aws.amazon.com/cli/latest/userguide/awscli-install-linux.html 
https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

How to :

Create aws key-pair

###### aws ec2 create-key-pair --key-name terraformwp --query 'KeyMaterial' --output text > ~/.ssh/terraformwp.pem

###### chmod 400 ~/.ssh/terraformwp.pem

###### aws ec2 create-key-pair --key-name bosh --query 'KeyMaterial' --output text > ~/.ssh/bosh.pem

###### chmod 400 ~/.ssh/bosh.pem

###### mkdir somedir

###### cd somedir

###### git clone https://github.com/SergeyMuha/aws-terraform-bosh-wordpress

###### cd aws-terraform-bosh-wordpress

###### terraform init

Deploy infrastructure. This command will output dns name for BOSH-HOST and subnet-id that you have to use when create bosh director

###### terraform apply -input=false -auto-approve

SSH to BOSH-HOST 
###### ssh -i ~/.ssh/terraformwp.pem ec2-user@BOSH-HOST

You are seeing errors due to export env variable  --vars-store=creds.yml doesn't exist

PRESS CNTRL+C

RUN:

###### cd ~/bosh

Set your subnet_id, access_key_id, secret_access_key and run 

###### bosh create-env bosh-deployment/bosh.yml     --state=state.json     --vars-store=creds.yml     -o bosh-deployment/aws/cpi.yml     -v director_name=bosh      -v region=eu-west-2     -v az=eu-west-2a    -v default_key_name=bosh     -v default_security_groups=[default]     --var-file private_key=~/.ssh/bosh.pem   -v BOSH_LOG_LEVEL=debug -v internal_cidr=192.168.0.0/26    -v internal_gw=192.168.0.1     -v internal_ip=192.168.0.7 -v subnet_id= -v access_key_id=    -v secret_access_key=

PRESS CNTRL+D and login again . Now creds.yml exists.

###### cd ~ && git clone https://github.com/SergeyMuha/bosh-wordpress

###### bosh  upload-stemcell --sha1 26fa116f4970eda6c52fce681732f0ddbf4f842a https://s3.amazonaws.com/bosh-core-stemcells/aws/bosh-stemcell-3541.12-aws-xen-hvm-ubuntu-trusty-go_agent.tgz

###### bosh update-cloud-config /home/ubuntu/bosh/bosh-deployment/aws/cloud-config.yml

###### cd ~/bosh-wordpress

###### bosh create-release

###### bosh upload-release

###### bosh deploy -d wordpress manifest.yml

RUN :
###### aws ec2 describe-instances --filters "Name=tag:deployment,Values=wordpress" | grep -m 1 -i dns | awk -F':' '{print $2}' | sed 's/"//g' | sed 's/,//g' | sed 's/ //g'

OPEN in browser

To destroy infrastructure use 

###### terraform destroy -input=false -auto-approve
