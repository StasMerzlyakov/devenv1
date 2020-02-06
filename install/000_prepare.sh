#!/bin/bash

# ! sudo required
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum install docker-ce docker-ce-cli containerd.io

systemctl start docker
systemctl enable docker
# create docker network
docker network create devenv1
docker pull centos:centos7

