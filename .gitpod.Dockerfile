FROM gitpod/workspace-full:latest

# Set debconf to noninteractive to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Nginx, MySQL, PHP-FPM, and required extensions
RUN sudo apt-get update && sudo apt-get install -y \
    nginx \
    mysql-server \
    php-fpm php-mysql \
    php-xml php-mbstring php-curl php-gd php-zip \
    mysql-client

# Configure Nginx to use PHP-FPM
RUN sudo mkdir -p /var/www/html && \
    sudo chown -R gitpod:gitpod /var/www/html && \
    echo "server { \
    listen 80; \
    root /var/www/html; \
    index index.php index.html index.htm; \
    location / { \
        try_files \$uri \$uri/ /index.php?\$query_string; \
    } \
    location ~ \.php$ { \
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock; \
        fastcgi_index index.php; \
        include fastcgi_params; \
    } \
}" | sudo tee /etc/nginx/sites-available/default

# Set up MySQL root password and create the database
RUN sudo service mysql start && \
    sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'adminroot';" && \
    sudo mysql -e "CREATE DATABASE IF NOT EXISTS wordpress;"

# Expose ports for MySQL and Nginx
EXPOSE 3306 80

# Allow passwordless sudo for the gitpod user
RUN echo "gitpod ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers

# Clean up
RUN sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

# Start Nginx and PHP-FPM
CMD sudo service nginx start && sudo service php8.1-fpm start && sudo tail -f /dev/null

