#!/bin/bash

# Start MySQL service
sudo service mysql start || sudo /etc/init.d/mysql start

# Create MySQL database for WordPress
mysql -u root -e "CREATE DATABASE IF NOT EXISTS wordpress;"

# Download WP-CLI for WordPress installation
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# Download WordPress
wp core download --path=/workspace/wordpress

# Set up wp-config.php with database details
wp config create --dbname=wordpress --dbuser=root --dbhost=localhost --path=/workspace/wordpress

# Install WordPress Multisite using environment variables for admin credentials
wp core multisite-install --url="http://localhost:8080" \
  --title="Gitpod Multisite" \
  --admin_user="${WP_ADMIN_USER}" \
  --admin_password="${WP_ADMIN_PASSWORD}" \
  --admin_email="${WP_ADMIN_EMAIL}" \
  --path=/workspace/wordpress
