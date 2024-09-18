#!/bin/bash

# Start MySQL service, using both options for compatibility
sudo service mysql start || sudo /etc/init.d/mysql start

# Start PHP-FPM service
sudo service php8.1-fpm start

# Start Nginx service
sudo service nginx start

# Wait for Gitpod to open port 80 and preview the site
gp await-port 80 && gp preview $(gp url 80)
