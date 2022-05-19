#!/bin/bash 
apt-get update && apt-get upgrade -y
sleep 5
sudo apt-get install php libapache2-mod-php -y
sleep 5
sudo apt install php-mysqli apache2 -y 
cd /var/www/html
rm index.html
git clone https://github.com/bhavaniveeramalli/testapp.git .

#sudo service apache2 restart
