#!/bin/bash

# Start MySQL service
sudo service mysql start || sudo /etc/init.d/mysql start

# Create MySQL database for WordPress using the Gitpod environment variable for the password
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS wordpress;"

# Download WP-CLI for WordPress installation
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# Download WordPress
wp core download --path=/workspace/multisite

# Get the Gitpod workspace URL dynamically
SITE_URL=$(gp url 8080)

# Set up wp-config.php with database details
wp config create --dbname=wordpress --dbuser=root --dbpass="${MYSQL_ROOT_PASSWORD}" --dbhost=localhost --path=/workspace/multisite

# Install WordPress Multisite using the dynamic Gitpod URL
wp core multisite-install --url="${SITE_URL}" \
  --title="Gitpod Multisite" \
  --admin_user="${WP_ADMIN_USER}" \
  --admin_password="${WP_ADMIN_PASSWORD}" \
  --admin_email="${WP_ADMIN_EMAIL}" \
  --path=/workspace/multisite

