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

# Fix any Apache config issues by forcing the maintainer's version
RUN sudo apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y apache2

# Expose ports for MySQL and Apache
EXPOSE 3306
EXPOSE 80

# Allow passwordless sudo for the gitpod user
RUN echo "gitpod ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

