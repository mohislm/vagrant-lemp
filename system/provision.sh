#!/usr/bin/env bash

# Update
apt-get update

# Set timezone and install NTP
echo "America/New_York" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata
apt-get install -y ntp

# Install build tools
apt-get install -y build-essential

# Install curl and git
apt-get install -y curl git

# Add the repositories to install the latest version of nginx and php5
apt-get install -y python-software-properties
add-apt-repository -y ppa:nginx/stable
add-apt-repository -y ppa:ondrej/php5
apt-get update

# Install PHP-FPM
apt-get install -y php5-fpm

# Also install php5-cli to run php in CLI with the usual "php" command
apt-get install -y php5-cli

# Install some common PHP extensions
apt-get install -y php5-mysql php5-curl php5-gd php5-mcrypt

# Install composer globally
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Install MySQL with root password `vagrant`
debconf-set-selections <<< "mysql-server mysql-server/root_password password vagrant"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password vagrant"
apt-get install -y mysql-server

# Install nginx
apt-get install -y nginx

# Create backup copy of existing config files (nginx.conf and mime.types)
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
cp /etc/nginx/mime.types /etc/nginx/mime.types.bak

# Create symlink to Nginx H5BP configuration files
mkdir /etc/nginx/conf
ln -sf /vagrant/system/nginx/nginx.conf /etc/nginx/nginx.conf
ln -sf /vagrant/system/nginx/mime.types /etc/nginx/mime.types
ln -s /vagrant/system/nginx/h5bp.conf /etc/nginx/conf/h5bp.conf
ln -s /vagrant/system/nginx/x-ua-compatible.conf /etc/nginx/conf/x-ua-compatible.conf
ln -s /vagrant/system/nginx/expires.conf /etc/nginx/conf/expires.conf
ln -s /vagrant/system/nginx/cross-domain-fonts.conf /etc/nginx/conf/cross-domain-fonts.conf
ln -s /vagrant/system/nginx/protect-system-files.conf /etc/nginx/conf/protect-system-files.conf

# Create logs directory
su - vagrant -c "mkdir /vagrant/system/logs && touch /vagrant/system/logs/error.log && touch /vagrant/system/logs/access.log"

# Symlink to the proper log directory
ln -s /var/log/nginx /etc/nginx/logs

# Configure default site using server.conf
mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
ln -s /vagrant/system/nginx/server.conf /etc/nginx/sites-available/default

# Disable autostart from default init.d
update-rc.d -f nginx disable

# Create upstart job for nginx
cp /vagrant/system/upstart/nginx.conf /etc/init/nginx.conf