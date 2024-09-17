#!/bin/bash

# Start MySQL service, using both options for compatibility
sudo service mysql start || sudo /etc/init.d/mysql start

# Start Apache service
sudo service apache2 start

# Wait for Gitpod to open port 8080 and preview the site
gp await-port 8080 && gp preview $(gp url 8080)
