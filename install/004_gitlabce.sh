#!/bin/bash

## !!! sudo required
[ ! -f ./variables ] && echo "file ./variables not exists" && exit 1

source ./variables

dd if=/dev/zero of=/swapfile count=4096 bs=1M
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile   none    swap    sw    0   0' | tee -a /etc/fstab
free -m

echo 'vm.swappiness=10' | tee -a /etc/sysctl.conf
sysctl -p



hostnamectl set-hostname $GITLAB_HOSTNAME
echo "$GITLAB_IP $GITLAB_HOSTNAME $GITLAB_DN" >> /etc/hosts

firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
systemctl reload firewalld.service


yum install -y epel-release
yum -y update

yum install -y curl policycoreutils-python openssh-server openssh-clients

## postfix install TODO (for send mail)
yum install -y postfix
systemctl enable postfix.service
systemctl start postfix.service
firewall-cmd --permanent --add-service=smtp
firewall-cmd --permanent --add-service=pop3
firewall-cmd --permanent --add-service=imap
firewall-cmd --permanent --add-service=smtps
firewall-cmd --permanent --add-service=pop3s
firewall-cmd --permanent --add-service=imaps
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload


curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | bash

EXTERNAL_URL="${GITLAB_DN}" yum install -y gitlab-ce

# gitlab ce configuration
# TODO
# gitlab_rails['gitlab_email_enabled'] = true
# gitlab_rails['gitlab_email_from'] = 'admin@itdraft.ru'
# gitlab_rails['gitlab_email_display_name'] = 'Admin'
# gitlab_rails['gitlab_email_reply_to'] = 'admin@itdraft.ru'
# gitlab_rails['smtp_enable'] = true
# gitlab_rails['smtp_address'] = "smtp.itdraft.ru"
# gitlab_rails['smtp_port'] = 465
# gitlab_rails['smtp_user_name'] = "admin"
# gitlab_rails['smtp_password'] = "%password%"
# gitlab_rails['smtp_domain'] = "itdraft.ru"
# gitlab_rails['gitlab_email_from'] = 'admin@itdraft.ru'
# gitlab_rails['smtp_authentication'] = "login"
# gitlab_rails['smtp_enable_starttls_auto'] = true
# gitlab_rails['smtp_tls'] = false
# gitlab_rails['smtp_openssl_verify_mode'] = 'peer'
#

gitlab-ctl reconfigure
gitlab-ctl start





