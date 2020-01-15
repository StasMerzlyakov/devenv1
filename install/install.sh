#!/bin/bash

# sudo required

# install apache2
apt -y install apache2 apache2-dev libcurl4-openssl-dev
apt -y install imagemagick libmagickwand-dev git build-essential automake libgmp-dev


# install postgresql
echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt update
apt -y install postgresql
systemctl start postgresql
systemctl enable postgresql


echo "Postgres passwd:"
passwd postgres

su - postgres -c 'createuser redmine'
su - postgres -c 'echo "ALTER USER redmine WITH ENCRYPTED password '\''redmine'\'';" | psql'
su - postgres -c 'echo "CREATE DATABASE redmine WITH ENCODING='\''UTF8'\'' OWNER=redmine;" | psql'
apt -y install libpqxx-dev protobuf-compiler

# pgadmin4



