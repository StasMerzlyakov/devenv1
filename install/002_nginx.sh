#!/bin/bash


distro=$(sed -n 's/^distroverpkg=//p' /etc/yum.conf)
releasever=$(rpm -q --qf "%{version}" -f /etc/$distro)
basearch=$(rpm -q --qf "%{arch}" -f /etc/$distro)

echo "[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/7/$basearch/
gpgcheck=0
enabled=1" > /etc/yum.repos.d/nginx.repo

yum -y install nginx
systemctl enable nginx




