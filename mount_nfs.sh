#!/bin/bash

##########################
# Auteur......: Guillaume
# Date........: 24/04/2022
# Version.....: 0.1
##########################

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
echo " "
ls /mnt/NAS
