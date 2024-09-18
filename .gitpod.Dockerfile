FROM gitpod/workspace-full:latest

# Set non-interactive frontend for apt
ENV DEBIAN_FRONTEND=noninteractive

# Remove Apache default config and install Apache, MySQL, PHP, and WordPress dependencies
RUN sudo apt-get update && \
    sudo apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql \
    php-xml php-mbstring php-curl php-gd php-zip php-imagick php-intl php-soap \
    mysql-client && \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && sudo mv wp-cli.phar /usr/local/bin/wp

# Setup Apache configuration for WordPress Multisite
RUN sudo mkdir -p /var/www/html && \
    sudo chown -R gitpod:gitpod /var/www/html && \
    echo "<VirtualHost *:8080>
    DocumentRoot /var/www/html
    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>
    </VirtualHost>" | sudo tee /etc/apache2/sites-available/000-default.conf && \
    sudo sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf

# Enable mod_rewrite for WordPress permalinks
RUN sudo a2enmod rewrite

# Allow the Gitpod user passwordless sudo
RUN echo "gitpod ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers

# Clean up
RUN sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

# Expose necessary ports
EXPOSE 8080 3306

# Start Apache and MySQL when the container is run
CMD sudo service mysql start && sudo service apache2 start && sudo tail -f /dev/null

