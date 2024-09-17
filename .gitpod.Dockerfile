FROM gitpod/workspace-full:latest

# Set debconf to noninteractive to avoid user prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Apache, MySQL, PHP, and required extensions
RUN sudo apt-get update && sudo apt-get install -y \
    apache2 \
    mysql-server \
    php libapache2-mod-php php-mysql \
    php-xml php-mbstring php-curl php-gd php-zip \
    mysql-client

# Enable Apache mod_rewrite for WordPress
RUN sudo a2enmod rewrite

# Force installation of Apache with default config, overriding the existing config prompt
RUN sudo apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y apache2

# Add a missing 'gp' environment variable manually to prevent related errors
RUN echo "export gp=''" >> /etc/apache2/envvars

# Fix any remaining Apache or PHP environment setup issues
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Reload Apache to ensure it catches new configurations
RUN sudo service apache2 restart

# Set up MySQL root password and database
RUN sudo service mysql start || sudo /etc/init.d/mysql start
RUN sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'adminroot';" \
    && sudo mysql -u root -p'adminroot' -e "CREATE DATABASE wordpress;"

# Expose ports for MySQL and Apache
EXPOSE 3306
EXPOSE 80

# Allow passwordless sudo for the gitpod user
RUN echo "gitpod ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


