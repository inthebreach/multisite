FROM gitpod/workspace-full:latest

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Update and install dependencies
RUN sudo apt-get update && \
    sudo apt-get remove -y apache2 apache2-* && \
    sudo apt-get autoremove -y && \
    sudo apt-get install -y --no-install-recommends \
    nginx \
    mysql-server \
    php8.3-fpm php8.3-mysql \
    php8.3-xml php8.3-mbstring php8.3-curl php8.3-gd php8.3-zip \
    php8.3-imagick php8.3-intl php8.3-soap \
    mysql-client \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*

# Configure Nginx to not prompt for config changes
RUN sudo sed -i 's/# server_names_hash_bucket_size 64;/server_names_hash_bucket_size 64;/' /etc/nginx/nginx.conf

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && sudo mv wp-cli.phar /usr/local/bin/wp

# Configure Nginx
RUN sudo rm -f /etc/nginx/sites-enabled/default
RUN echo "server { \
    listen 80; \
    root /workspace/multisite/wordpress; \
    index index.php index.html index.htm; \
    location / { \
        try_files \$uri \$uri/ /index.php?\$query_string; \
    } \
    location ~ \.php$ { \
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock; \
        fastcgi_index index.php; \
        include fastcgi_params; \
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; \
    } \
}" | sudo tee /etc/nginx/sites-available/wordpress
RUN sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/

# Configure PHP
RUN sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.3/fpm/php.ini \
    && sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/' /etc/php/8.3/fpm/php.ini \
    && sudo sed -i 's/post_max_size = 8M/post_max_size = 64M/' /etc/php/8.3/fpm/php.ini \
    && sudo sed -i 's/memory_limit = 128M/memory_limit = 256M/' /etc/php/8.3/fpm/php.ini

# Set up MySQL
RUN sudo mkdir -p /var/run/mysqld \
    && sudo chown -R gitpod:gitpod /var/run/mysqld \
    && sudo chown -R gitpod:gitpod /var/lib/mysql \
    && sudo chown -R gitpod:gitpod /etc/mysql

# Initialize MySQL data directory
RUN sudo mysqld --initialize-insecure

# Set up MySQL root password and create the database
RUN sudo service mysql start && \
    sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';" && \
    sudo mysql -e "CREATE DATABASE IF NOT EXISTS wordpress;"

# Allow passwordless sudo for Gitpod user
RUN echo "gitpod ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers

# Expose ports
EXPOSE 80 3306

# Start Nginx, PHP-FPM, and MySQL
CMD sudo service mysql start && sudo service php8.3-fpm start && sudo nginx -g 'daemon off;'
