#!/bin/bash

#maj système
sudo apt-get update
sudo apt-get upgrade -y

#installation apache
sudo apt-get install apache2 -y

#récupère les fichiers on le dezip
sudo wget https://github.com/Alaixs/SaeRes/archive/refs/heads/main.zip
unzip main.zip

#on bouge les fichiers dans leur endroits respectif
sudo mv SaeRes-main/intranet.conf /etc/apache2/sites-available/
sudo mv SaeRes-main/public.conf /etc/apache2/sites-available/
sudo mv SaeRes-main/default.conf /etc/apache2/sites-available/
sudo mv SaeRes-main/srv ../../

#on ajoute dans le fichier host les redirections url
IP=$(hostname -I | awk '{print $1}')
echo "$IP  www.tek-it-izy.org" | sudo tee -a /etc/hosts
echo "$IP intranet.tek-it-izy.org" | sudo tee -a /etc/hosts

#on ajoute dans le fichier conf de apache l’index pour parcourir les dossiers
sudo mkdir /srv/www/public/emptydir
sudo sed -i "/<Directory srv/www/public>/,/<\/Directory>/ s/Options \(.*\)/Options Indexes \1/" /etc/apache2/sites-available/public.conf

#ajouter les autorisations
sudo chown -R admin:www-data /srv/www/public/index.html
sudo chown -R admin:www-data /srv/intranet/index.html
sudo chown -R admin:www-data /var/www/html/index.html
sudo chmod -R 775 /srv/www/public/index.html
sudo chmod -R 775 /srv/intranet/index.html
sudo chmod -R 775 /var/www/html/index.html

# on ajoute le port 2080 dans le fichier /etc/apache2/ports.conf
echo "Listen 2080" | sudo tee -a /etc/apache2/ports.conf > /dev/null

#on ajoute met à jours notre apache
sudo a2ensite intranet.conf
sudo a2ensite public.conf
sudo a2ensite default.conf

#redemarrage apache
sudo service apache2 restart
