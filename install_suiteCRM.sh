#!/bin/bash

# To run this command change permissions to executable (chmod 755 install_suiteCRM.sh)
# call this command to run ./install_suiteCRM.sh


# Update system packages
sudo apt update
sudo apt upgrade -y

# Install required dependencies
sudo apt install -y apache2 mariadb-server libapache2-mod-php php-gd php-json php-curl php-mbstring php-intl php-mysql php-xml php-zip

# Enable Apache mod_rewrite module
sudo a2enmod rewrite
sudo systemctl restart apache2

# Secure MariaDB installation
sudo mysql_secure_installation

# Create database and user for SuiteCRM
sudo mysql -u root <<EOF
CREATE DATABASE suitecrm;
CREATE USER 'suitecrm_user'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON suitecrm.* TO 'suitecrm'@'localhost';
FLUSH PRIVILEGES;
EOF

# Download and unzip SuiteCRM
wget https://suitecrm.com/download/128/suite82/561949/suitecrm-8-2-3.zip
unzip SuiteCRM-8-2-3.zip - /var/www/html/suitecrm

# Set correct permissions for SuiteCRM folder
sudo chown -R www-data:www-data /var/www/html/suitecrm
sudo chmod -R 755 /var/www/html/suitecrm

# Create virtual host configuration file
sudo bash -c "cat > /etc/apache2/sites-available/suitecrm.conf <<EOF
<VirtualHost *:80>
    ServerAdmin admin@example.com
    ServerName suiteserver.com
    DocumentRoot /var/www/html/suitecrm

    <Directory /var/www/html/suitecrm>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF"

# Enable virtual host
sudo a2ensite suitecrm
sudo systemctl reload apache2

# Go to http://suiteserver.com/install.php to start the installation process 