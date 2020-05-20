#!/bin/bash


distro=$(sed -n 's/^distroverpkg=//p' /etc/yum.conf)
releasever=$(rpm -q --qf "%{version}" -f /etc/$distro)
basearch=$(rpm -q --qf "%{arch}" -f /etc/$distro)

echo "[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=0
enabled=1" > /etc/yum.repos.d/nginx.repo

yum -y install nginx
systemctl enable nginx

# sample
# echo "upstream authproxy {
#     server localhost:8080;
# }
# 
# server {
#     listen 9090 default;
#     location / {
#         proxy_pass http://authproxy;
#         proxy_http_version 1.1;
#         proxy_set_header Upgrade $http_upgrade;
#         proxy_set_header Connection "upgrade";
#     }
# }" > /etc/nginx/conf.d/authproxy.conf
# 
# systemctl start nginx
# 
# 
# # fix SELinux
# setsebool -P httpd_can_network_connect 1
# 
# 
# 
