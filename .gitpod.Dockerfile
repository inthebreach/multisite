FROM gitpod/workspace-full:latest

# Install Apache, MySQL, PHP, and required extensions
RUN sudo apt-get update && sudo apt-get install -y \
    apache2 \
    mysql-server \
    php libapache2-mod-php php-mysql \
    php-xml php-mbstring php-curl php-gd php-zip

# Enable Apache mod_rewrite for WordPress
RUN sudo a2enmod rewrite

# Start MySQL during the container start
RUN sudo service mysql start
