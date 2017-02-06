#!/bin/bash

export ENVIRONMENT=${environment}
echo "Environment is $ENVIRONMENT"

# install deps
yum update -y
yum install -y git nfs-utils

# mount network fileystems
service nfs start
mkdir -p /mnt/jade-notebooks
mount -t nfs4 -o nfsvers=4.1 $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).fs-841df44d.efs.eu-west-1.amazonaws.com:/ /mnt/jade-notebooks

# install docker
yum install -y docker

# Start Docker
service docker start

# Install Docker Compose
curl -L https://github.com/docker/compose/releases/download/1.6.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
usermod -aG docker ec2-user

# get config
git clone https://github.com/met-office-lab/jade.git /usr/local/share/jade

# get keys
aws s3 cp s3://jade-secrets/${jade-secrets-file} /usr/local/share/jade/jade-secrets

# run config

cat /usr/local/share/jade/jade-secrets /usr/local/share/jade/docker/master/${host_env_file} > /usr/local/share/jade/docker/master/all.env

/usr/local/bin/docker-compose -f /usr/local/share/jade/docker/master/docker-compose.yml up -d
