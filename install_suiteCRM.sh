#!/bin/bash

# update the package list and upgrade the existing packages
sudo apt update
sudo apt upgrade -y

# install the required packages
sudo apt install apache2 mariadb-server php php-mysql libapache2-mod-php unzip -y

# enable the Apache rewrite module
sudo a2enmod rewrite

# restart Apache
sudo systemctl restart apache2

# create the database and user for SuiteCRM
sudo mysql <<EOF
CREATE DATABASE suitecrm;
CREATE USER 'suitecrm'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON suitecrm.* TO 'suitecrm'@'localhost';
FLUSH PRIVILEGES;
EOF

# download and extract the latest version of SuiteCRM
LATEST_VERSION=$(curl -s https://api.github.com/repos/salesagility/SuiteCRM/releases/latest | grep 'tag_name' | cut -d\" -f4)
wget https://github.com/salesagility/SuiteCRM/releases/download/${LATEST_VERSION}/SuiteCRM-${LATEST_VERSION}.zip
unzip SuiteCRM-${LATEST_VERSION}.zip
sudo mv SuiteCRM-${LATEST_VERSION} /var/www/html/suitecrm

# create a virtual host configuration for SuiteCRM
sudo bash -c "cat > /etc/apache2/sites-available/suitecrm.conf <<EOF
<VirtualHost *:80>
    ServerName example.com
    DocumentRoot /var/www/html/suitecrm
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    <Directory /var/www/html/suitecrm>
        Options +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF"

# enable the virtual host and restart Apache
sudo a2ensite suitecrm
sudo systemctl restart apache2
