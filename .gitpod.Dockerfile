FROM gitpod/workspace-full:latest

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Update and install dependencies
RUN sudo apt-get update && \
    sudo apt-get install -y \
    nginx \
    mysql-server \
    php-fpm php-mysql \
    php-xml php-mbstring php-curl php-gd php-zip \
    php-imagick php-intl php-soap \
    mysql-client \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && sudo mv wp-cli.phar /usr/local/bin/wp

# Copy Nginx configuration
COPY nginx-wordpress.conf /etc/nginx/sites-available/wordpress
RUN sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/ \
    && sudo rm /etc/nginx/sites-enabled/default

# Configure PHP
RUN sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.1/fpm/php.ini \
    && sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/' /etc/php/8.1/fpm/php.ini \
    && sudo sed -i 's/post_max_size = 8M/post_max_size = 64M/' /etc/php/8.1/fpm/php.ini \
    && sudo sed -i 's/memory_limit = 128M/memory_limit = 256M/' /etc/php/8.1/fpm/php.ini

# Set up MySQL
RUN sudo mkdir -p /var/run/mysqld \
    && sudo chown -R gitpod:gitpod /var/run/mysqld \
    && sudo chown -R gitpod:gitpod /var/lib/mysql \
    && sudo chown -R gitpod:gitpod /etc/mysql

# Initialize MySQL data directory
RUN sudo mysqld --initialize-insecure

# Allow passwordless sudo for Gitpod user
RUN echo "gitpod ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers

# Expose ports
EXPOSE 80 3306

# Start Nginx, PHP-FPM, and MySQL
CMD sudo service nginx start && sudo service php8.1-fpm start && sudo mysqld
