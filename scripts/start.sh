#!/bin/bash

# Start MySQL and Apache services
sudo service mysql start
sudo service apache2 start

# Await Gitpod port opening and output the WordPress site URL
gp await-port 8080 && echo "WordPress is running on http://localhost:8080"
