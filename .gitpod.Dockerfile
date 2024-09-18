FROM gitpod/workspace-full:latest

# Set debconf to noninteractive to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install MySQL, PHP, and required extensions
RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
    mysql-server \
    php libapache2-mod-php php-mysql \
    php-xml php-mbstring php-curl php-gd php-zip \
    php-imagick php-intl php-soap \
    && sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && sudo mv wp-cli.phar /usr/local/bin/wp

# Enable Apache mod_rewrite for WordPress
RUN sudo a2enmod rewrite

# Configure PHP for better performance
RUN sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/*/apache2/php.ini && \
    sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/' /etc/php/*/apache2/php.ini && \
    sudo sed -i 's/post_max_size = 8M/post_max_size = 64M/' /etc/php/*/apache2/php.ini && \
    sudo sed -i 's/memory_limit = 128M/memory_limit = 256M/' /etc/php/*/apache2/php.ini

# Fix Apache configuration
RUN sudo sed -i 's/${GITPOD_REPO_ROOT}/\/workspace\/multisite/g' /etc/apache2/apache2.conf

# Expose necessary ports
EXPOSE 80 3306
