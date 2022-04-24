#!/bin/bash
#####################################################
# Auteur......: Guillaume
# Date........: 24/04/2022
# Version.....: 0.1
#####################################################
echo "Mise à jour des paquets..."
sleep 2
sudo apt update
clear
echo "Installation du paquet nfs-common"
sleep 2
sudo apt install -y nfs-common || echo "Echec de l'installation de nfs-common"
sleep 2
clear
echo "Installation de docker et docker-compose"
sleep 2
sudo apt install -y docker docker-compose || echo "Echec de l'installation de docker et docker-compose"
clear
echo "Test de l'installation de docker"
sleep 2
sudo docker run hello-world || echo "Docker ne fonctionne pas correctement"
sleep 2
clear

echo "Montage du dossier NFS"
echo "Rentrez l'IP de votre NAS Synology: "
read x
echo "Rentrer le chemin de votre NAS: (exemple: /volume1/Media)"
read y
ls /mnt/NAS || sudo mkdir /mnt/NAS
sudo mount -t nfs $x:$y /mnt/NAS
sudo echo "$x:$y /mnt/NAS nfs defaults,auto 0 0" >> /etc/fstab
clear
echo "Liste des dossiers :"
ls /mnt/NAS
