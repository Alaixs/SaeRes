#!/bin/bash

#maj système
sudo apt-get update
sudo apt-get upgrade -y

#Change le layout du keyboard
sudo raspi-config nonint do_change_keyboard_layout fr

#changement des paramètres réseaux
sudo sed -i 's/^.*$/nameserver 10.2.40.230/' /etc/resolv.conf
echo "static ip_adress=10.192.51.245/16" | sudo tee -a /etc/dhcpcd.conf
echo "static routers=10.192.0.255" | sudo tee -a /etc/dhcpcd.conf

#installation apache
sudo apt-get install apache2 -y

#récupère les fichiers on le dezip
sudo wget https://github.com/Alaixs/SaeRes/archive/refs/heads/main.zip
unzip main.zip

#on bouge les fichiers dans leur endroits respectif
sudo mv SaeRes-main/intranet.conf /etc/apache2/sites-available/
sudo mv SaeRes-main/public.conf /etc/apache2/sites-available/
sudo mv SaeRes-main/default.conf /etc/apache2/sites-available/
sudo mv SaeRes-main/srv ../../../

#on ajoute dans le fichier host les redirections url
IP=$(hostname -I | awk '{print $1}')
echo "$IP  www.tek-it-izy.org" | sudo tee -a /etc/hosts
echo "$IP intranet.tek-it-izy.org" | sudo tee -a /etc/hosts

#on ajoute dans le fichier conf de apache l’index pour parcourir les dossiers
sudo mkdir /srv/www/public/emptydir
sudo sed -i "/<Directory srv/www/public>/,/<\/Directory>/ s/Options \(.*\)/Options Indexes \1/" /etc/apache2/sites-available/public.conf

#ajouter les autorisations
sudo chmod -R 755 /srv/www/
sudo chown -R www-data:www-data /srv/www/


#on ajoute met à jours notre apache
sudo a2ensite intranet.conf
sudo a2ensite public.conf
sudo a2ensite default.conf

#redemarrage apache
sudo systemctl restart apache2
