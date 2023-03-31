#!/bin/bash

#maj système
sudo apt-get update
sudo apt-get upgrade -y

#installation apache
sudo apt-get install apache2 -y

#installation php
sudo apt-get install php -y

#récupère les fichiers on le dezip
sudo wget https://github.com/Alaixs/SaeRes/archive/refs/heads/main.zip
unzip main.zip

#on bouge les fichiers dans leur endroits respectif
sudo mv html /var/www/
sudo mv SaeRes-main/intranet.conf /etc/apache2/sites-available/
sudo mv SaeRes-main/public.conf /etc/apache2/sites-available/
sudo mv SaeRes-main/srv ../../

#on ajoute dans le fichier host les redirections url
IP=$(hostname -I | awk '{print $1}')
echo "$IP  www.tek-it-izy.org" | sudo tee -a /etc/hosts
echo "$IP intranet.tek-it-izy.org" | sudo tee -a /etc/hosts
echo "$IP raspb245.univ-lr.fr" | sudo tee -a /etc/hosts

#Ajoute des users pour test site par défaut
sudo useradd -m -s /bin/bash -p $(openssl passwd -1 'tanguy') ytanguy
sudo useradd -m -s /bin/bash -p $(openssl passwd -1 'cody') scody

sudo mkdir /var/www/html/ytanguy
sudo mkdir /var/www/html/scody

sudo chmod -R u+rwx /var/www/html/ytanguy
sudo chmod -R u+rwx /var/www/html/scody


#on ajoute dans le fichier conf de apache l’index pour parcourir les dossiers
#???
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

#redemarrage apache
sudo service apache2 restart
