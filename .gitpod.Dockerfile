FROM gitpod/workspace-full:latest

# Install Apache, MySQL, PHP, and required extensions
RUN sudo apt-get update && sudo apt-get install -y \
    apache2 \
    mysql-server \
    php libapache2-mod-php php-mysql \
    php-xml php-mbstring php-curl php-gd php-zip

# Enable Apache mod_rewrite for WordPress
RUN sudo a2enmod rewrite

# Start MySQL and set up root password using the Gitpod environment variable
RUN sudo service mysql start || sudo /etc/init.d/mysql start \
    && sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';" \
    && sudo mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE wordpress;"

# Expose ports for MySQL and Apache
EXPOSE 3306
EXPOSE 80
