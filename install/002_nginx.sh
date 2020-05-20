#!/bin/bash

[ ! -f ./variables ] && echo "file ./variables not exists" && exit 1

source ./variables

echo "[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/7/$basearch/
gpgcheck=0
enabled=1" > /etc/yum.repos.d/nginx.repo

yum -y install nginx
systemctl enable nginx
