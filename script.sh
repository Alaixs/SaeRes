#!/bin/bash

#maj système
sudo apt-get update
sudo apt-get upgrade -y

#install apache
sudo apt-get install apache2 -y

#install php
sudo apt-get install php -y

#recovery of files on the dezip
sudo wget https://github.com/Alaixs/SaeRes/archive/refs/heads/main.zip
unzip main.zip

#loading the default site
sudo rm -r /var/www/html/
sudo mv SaeRes-main/html /var/www/

#move the files to their respective locations
sudo mv SaeRes-main/intranet.conf /etc/apache2/sites-available/
sudo mv SaeRes-main/public.conf /etc/apache2/sites-available/
sudo mv SaeRes-main/000-default.conf /etc/apache2/sites-available/
sudo mv SaeRes-main/srv ../../

#add in the host file the url redirections
IP=$(hostname -I | awk '{print $1}')
echo "$IP  www.tek-it-izy.org" | sudo tee -a /etc/hosts
echo "$IP intranet.tek-it-izy.org" | sudo tee -a /etc/hosts
echo "$IP raspb245.univ-lr.fr" | sudo tee -a /etc/hosts

#Add users for test site by default
sudo useradd -m -s /bin/bash -p $(openssl passwd -1 'tanguy') ytanguy
sudo useradd -m -s /bin/bash -p $(openssl passwd -1 'cody') scody

#Add rights to the user for their own folder
sudo chown -R scody:scody /var/www/html/scody
sudo chmod -R ug+rwX /var/www/html/scody
sudo chown -R ytanguy:ytanguy /var/www/html/ytanguy
sudo chmod -R ug+rwX /var/www/html/ytanguy

#We add the password for the intranet site
echo 'T&k!t!zY' | sudo htpasswd -c -i /etc/apache2/.htpasswd intranet

#remove placeholders
sudo rm /srv/www/public/testFolder/emptyFolder/placeholder
sudo rm /srv/intranet/testFolder/emptyFolder/placeholder
sudo rm /srv/www/public/log/acces/placeholder
sudo rm /srv/www/public/log/erreur/placeholder
sudo rm /srv/intranet/log/acces/placeholder
sudo rm /srv/intranet/log/erreur/placeholder

#Change permission for test page error
chmod go-r /srv/intranet/chmodgo-r.html
chmod go-r /srv/www/public/chmodgo-r.html

#add permissions
sudo chown -R admin:www-data /srv/www/public/index.html
sudo chown -R admin:www-data /srv/intranet/index.html
sudo chown -R admin:www-data /var/www/html/index.html
sudo chmod -R 775 /srv/www/public/index.html
sudo chmod -R 775 /srv/intranet/index.html
sudo chmod -R 775 /var/www/html/index.html

# we add the port 2080 in the file /etc/apache2/ports.conf
echo "Listen 2080" | sudo tee -a /etc/apache2/ports.conf > /dev/null

#we activate the new sites
sudo a2ensite intranet.conf
sudo a2ensite public.conf

#restart apache
sudo service apache2 restart

clear

#check if the script is installed correctly
if ! command -v apache2 >/dev/null || ! command -v php >/dev/null || [ ! -d /srv/ ] || [ ! -f /var/www/html/index.html ] || [ ! -f /etc/apache2/sites-available/intranet.conf ] || [ ! -f /etc/apache2/sites-available/public.conf ] || [ ! -f /etc/apache2/sites-available/000-default.conf ] || [ ! -f /etc/apache2/.htpasswd ]; then
  echo "Error: there is a problem with the installation, check the location of the files or repeat the steps in the manual. ❌"
  exit 1
else
  echo "The script has installed successfully, your server is ready to use! ✅"
 fi
