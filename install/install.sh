#!/bin/bash

# !!! sudo required

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
# http://localhost/pgadmin4
apt install pgadmin4 pgadmin4-apache2

# ruby
apt-add-repository -y ppa:rael-gc/rvm
apt update
apt -y install rvm
su -c 'echo "source /etc/profile.d/rvm.sh" | tee -a /etc/profile'
su -c 'source /etc/profile.d/rvm.sh && rvm install 2.6.5 && rvm use 2.6.5 --default && gem install bundler'

su -c 'source /etc/profile.d/rvm.sh && gem install passenger && passenger-install-apache2-module'



# install redmine
adduser --disabled-password --gecos "Redmine User" redmine
su - redmine -c 'cd ~
wget https://www.redmine.org/releases/redmine-4.1.0.tar.gz
tar -xf redmine-*.tar.gz
mv redmine-*/ redmine/
cd redmine
cp config/configuration.yml.example config/configuration.yml
cp config/database.yml.example config/database.yml

echo "# PostgreSQL configuration example
production:
  adapter: postgresql
  database: redmine
  host: localhost
  username: redmine
  password: \"redmine\"
" > config/database.yml
bundle config build.pg --with-pg-config=/usr/bin/pg_config
bundle install --path vendor/bundle --without development test
bundle exec rake generate_secret_token
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake redmine:load_default_data

mkdir -p tmp tmp/pdf public/plugin_assets
chown -R redmine:redmine files log tmp public/plugin_assets
chmod -R 755 files log tmp public/plugin_assets
'

echo "LoadModule passenger_module /usr/share/rvm/gems/ruby-2.6.5/gems/passenger-6.0.4/buildout/apache2/mod_passenger.so" | sudo tee -a /etc/apache2/apache2.conf



# install Configure Apache


