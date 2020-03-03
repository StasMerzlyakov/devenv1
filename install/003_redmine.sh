#!/bin/bash

## !!! sudo required
[ ! -f ./variables ] && echo "file ./variables not exists" && exit 1

source ./variables
[ -z $REDMINE_PASSWORD ] && echo "REDMINE_PASSWORD not set" && exit 1
[ -z $WEB_DOMAIN ] && echo "WEB_DOMAIN not set" && exit 1


## install postgresql
yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

yum -y install epel-release yum-utils
yum-config-manager --enable pgdg12
yum install -y postgresql12-server postgresql12
/usr/pgsql-12/bin/postgresql-12-setup initdb
systemctl enable --now postgresql-12

su - postgres -c 'createuser redmine'
su - postgres << EOF
   echo "ALTER USER redmine WITH ENCRYPTED password '"$REDMINE_PASSWORD"';" | psql
EOF

su - postgres -c 'echo "CREATE DATABASE redmine WITH ENCODING='\''UTF8'\'' OWNER=redmine;" | psql'


cp /var/lib/pgsql/12/data/pg_hba.conf /var/lib/pgsql/12/data/pg_hba.conf.back
yum install -y patch
patch /var/lib/pgsql/12/data/pg_hba.conf pg_hba.conf.patch
systemctl restart postgresql-12.service

yum install -y libpqxx-dev protobuf-compiler

## install httpd
yum -y install httpd gcc-c++ patch readline readline-devel zlib zlib-devel ibffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl-devel openssl-devel httpd-devel apr-devel apr-util-devel postgresql12-devel

## ruby
curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
curl -L get.rvm.io | bash -s stable

su -c 'source /etc/profile.d/rvm.sh && rvm reload && rvm requirements run && rvm install 2.6.5 && rvm use 2.6.5 --default && gem install bundler'
su -c 'source /etc/profile.d/rvm.sh && gem install passenger'
su -c 'source /etc/profile.d/rvm.sh && passenger-install-apache2-module -a'


## install redmine
adduser -c "Redmine User" redmine
mkdir /opt/redmine
chmod -R 755 /opt/redmine
chown -R redmine:redmine /opt/redmine
su - redmine << EOF
cd /opt/redmine
wget https://www.redmine.org/releases/redmine-4.1.0.tar.gz
tar -xf redmine-*.tar.gz
mv redmine-*/* ./
rm -rf redmine-*
cp config/configuration.yml.example config/configuration.yml
cp config/database.yml.example config/database.yml

echo "# PostgreSQL configuration example
production:
  adapter: postgresql
  database: redmine
  host: localhost
  username: redmine
  password: \"${REDMINE_PASSWORD}\"
" > config/database.yml
bundle config build.pg --with-pg-config=/usr/pgsql-12/bin/pg_config
bundle install --path vendor/bundle --without development test
bundle exec rake generate_secret_token
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production REDMINE_LANG=ru  bundle exec rake redmine:load_default_data

mkdir -p tmp tmp/pdf public/plugin_assets
chown -R redmine:redmine files log tmp public/plugin_assets
chmod -R 755 files log tmp public/plugin_assets
EOF

# install Config-ure Apache


echo "LoadModule passenger_module /usr/local/rvm/gems/ruby-2.6.5/gems/passenger-6.0.4/buildout/apache2/mod_passenger.so
<IfModule mod_passenger.c>
   PassengerRoot /usr/local/rvm/gems/ruby-2.6.5/gems/passenger-6.0.4
   PassengerDefaultRuby /usr/local/rvm/gems/ruby-2.6.5/wrappers/ruby
 </IfModule>" > /etc/httpd/conf.modules.d/02-passenger.conf

echo "Listen 3000
<VirtualHost *:3000>
    DocumentRoot /opt/redmine/public
    ServerName ${WEB_DOMAIN}
    RailsEnv production
    PassengerUser redmine
    <Directory /opt/redmine/public>
      Allow from all
      Options -MultiViews
      Require all granted
    </Directory>
</VirtualHost>
" > /etc/httpd/conf.d/redmine.conf
#a2enmod passenger
#a2ensite redmine
systemctl restart httpd
systemctl enable httpd

#disable selinux
patch /etc/selinux/config  selinux_config.patch

#reboot
reboot
