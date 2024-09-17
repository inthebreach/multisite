#!/bin/bash

# Start MySQL service, fallback to /etc/init.d if needed
sudo service mysql start || sudo /etc/init.d/mysql start

# Check if MySQL started successfully
if ! mysqladmin ping -u root --password="${MYSQL_ROOT_PASSWORD}" --silent; then
    echo "MySQL failed to start."
    exit 1
fi

# Create MySQL database for WordPress using the Gitpod environment variable for the password
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS wordpress;" || { echo "Failed to create the database"; exit 1; }

# Download WP-CLI if it does not exist
if ! command -v wp &> /dev/null; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    sudo mv wp-cli.phar /usr/local/bin/wp
fi

# Ensure WordPress is not already downloaded to prevent overwriting
if [ ! -f /workspace/multisite/wp-config.php ]; then
    # Download WordPress
    wp core download --path=/workspace/multisite || { echo "Failed to download WordPress"; exit 1; }
fi

# Get the Gitpod workspace URL dynamically
SITE_URL=$(gp url 8080)

# Set up wp-config.php with database details if it does not exist
if [ ! -f /workspace/multisite/wp-config.php ]; then
    wp config create --dbname=wordpress --dbuser=root --dbpass="${MYSQL_ROOT_PASSWORD}" --dbhost=localhost --path=/workspace/multisite || { echo "Failed to create wp-config.php"; exit 1; }
fi

# Install WordPress Multisite using the dynamic Gitpod URL
wp core multisite-install --url="${SITE_URL}" \
  --title="Gitpod Multisite" \
  --admin_user="${WP_ADMIN_USER}" \
  --admin_password="${WP_ADMIN_PASSWORD}" \
  --admin_email="${WP_ADMIN_EMAIL}" \
  --path=/workspace/multisite || { echo "Failed to install WordPress Multisite"; exit 1; }

echo "WordPress Multisite installed successfully!"


