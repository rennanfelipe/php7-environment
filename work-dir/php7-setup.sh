#!/bin/bash --login

#Author: Rennan Felipe
#Email: rennan.chaves95@gmail.com
#Version: 0.0.1
#Licence: MIT 
#Description: Scrip file to automate the PHP7 environment installation
#Fonts: Code based on the follow article: https://www.ostechnix.com/install-apache-mysql-php-lamp-stack-on-ubuntu-18-04-lts/

if [ "$USER" = 'root' ]
then
    echo ""
    echo "Only set sudo when asked!"
    echo ""
    exit 9
fi

history -c

echo "Update the enviroment"
sudo apt-get update -y
sudo apt-get install dialog -y

echo "Install Node.js and Yarn"
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update -y
sudo apt-get install gcc g++ make git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev nodejs yarn -y

echo "Configure git"
user=$(dialog --title "GIT CONFIGURATION" --inputbox "Put your git username and press enter:" 10 30 --output-fd 1)
email=$(dialog --title "GIT CONFIGURATION" --inputbox "Put your git email and press enter:" 10 30 --output-fd 1)

git config --global color.ui true
git config --global user.name $user
git config --global user.email $email
ssh-keygen -t rsa -b 4096 -C $email

echo "Install MySQL"
sudo apt-get install mysql-server mysql-client libmysqlclient-dev -y
mysql_secure_installation

echo "Install Apache"
sudo apt-get install apache2 -y

echo "Install PHP7"
sudo apt-get install php libapache2-mod-php php-mysql -y

sudo echo '<?php phpinfo(); ?>' > /var/www/index.php 

sudo systemctl restart apache2

sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php -r "if (hash_file('sha384', 'composer-setup.php') === 'a5c698ffe4b8e849a443b120cd5ba38043260d5c4023dbf93e1558871f1f07f58274fc6f4c93bcfd858c6bd0775cd8d1') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php composer-setup.php
sudo php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer

dt=$(date +"%Y%m%d%H%M%S")

echo $dt > .step1

exit 
