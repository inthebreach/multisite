FROM gitpod/workspace-full:latest

# Install Apache, MySQL, PHP, and required extensions
RUN sudo apt-get update && sudo apt-get install -y \
    apache2 \
    mysql-server \
    php libapache2-mod-php php-mysql \
    php-xml php-mbstring php-curl php-gd php-zip \
    mysql-client

# Enable Apache mod_rewrite for WordPress
RUN sudo a2enmod rewrite

# Expose ports for MySQL and Apache
EXPOSE 3306
EXPOSE 80

# Set passwordless sudo for gitpod user
RUN echo "gitpod ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
