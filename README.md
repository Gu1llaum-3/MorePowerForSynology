# More Power For Synology

> Le but de cette procédure est d'utiliser la puissance d'un autre ordinateur pour nos services à la place d'un NAS Synology n'ayant pas assez de puissance ou ne pouvant utiliser docker.

## Pré requis

- Un NAS Synology
  
- Un Raspberry Pi3/4 ou tout autre ordinateur sous linux qui servira de serveur
  
- Que le serveur et le nas soient connectés sur la même box ou le même switch afin d'avoir le meilleur débit possible en transfert.
  

## Synology

Afin de pouvoir utiliser les données sur le NAS, il va falloir mettre en place un partage NFS entre le NAS et le serveur. Il faut donc choisir quels sont le ou les dossier(s) que l'on souhaite partager. Ici, je vais partager un dossier appelé **Media**.

<u>Pour cela :</u>

- Connectez-vous à l'interface de votre nas
  
- Allez dans **Panneau de configuration** > **Services de fichiers**
  
- Ici, <u>cliquez</u> sur **NFS** et, si ce n'est pas déjà fait, <u>cliquez</u> sur **Activer le service NFS**
  
- Dans **Protocol NFS maximum**, renseignez **NFSv4.1**

- Allez ensuite dans **Dossier partagé** puis cliquez sur le dossier que vous souhaitez utiliser sur votre serveur. Pour moi ce sera **Media**
  
- Une fois le dossier séléctionné, tout en haut cliquez sur **Modifier**
  
- Dans la nouvelle fenêtre, cliquez sur **Autorisation NFS** puis **Créer**
  
  - **Non d'hôte ou IP :** Mettre l'IP de votre serveur (<u>mettez bien une IP Fixe dessus !</u>)
    
  - **Privilège :** **Lecture seule** <u>si vous ne voulez pas que les services mais aussi votre serveur modifie les fichiers</u>, sinon vous pouvez mettre **Lecture/écriture**
    
  - **Squash :** Mappage de tous les utilisateurs sur admin
    
  - **Sécurité :** sys
    
  - Cochez **Activer le mode asynchrone** et **Permettre à des utilisateurs d'accéder aux sous-dossiers montés**

C'est fini du côté du NAS, place au serveur

## Serveur

Nous allons maintenant faire en sorte de monter le partage NFS sur le serveur afin que les données soient accessible directement dessus.

Pour cela :

- Se connecter en **SSH** <u>avec son utilisateur sudo</u>
  
- Installer les paquets nécessaires :
  

```bash
sudo apt update && sudo apt install -y nfs-common
```

- Aller dans /mnt et créez un dossier nommé NAS

```bash
cd /mnt
sudo mkdir NAS
```

- On va ensuite tester le montage du dossier dans NAS

```bash
# Voici la commande :
sudo mount -t nfs <IP de votre NAS>:/volume1/votre_dossier /mnt/NAS
```

Attention, il faut bien mettre le chemin entier avec le volume où est stocké votre dossier, ici pour moi c'est le volume1 mais ça peut-être volume2/3/4.
Pour savoir sur quel volume est votre dosser, il suffit d'aller dans **Panneau de configuration** > **Dossier partagé** et regarder sur quel volume se situe votre dossier.

- Voici ce que la commande donne de mon côté :
  

```bash
sudo mount -t nfs 192.168.1.105:/volume1/Media /mnt/NAS
```

- Si tout c'est bien passé, la commande ne renvoie pas d'erreur, il ne reste plus qu'à vérifier que vos dossiers et fichiers sont bien là.
  

```bash
guillaume@docker:/mnt$ cd NAS
guillaume@docker:/mnt/NAS$ ls
 Films   Musiques  '#recycle'   Séries
```

On peut voir que j'ai maintenant accès aux dossier de mon NAS

**Attention**, <u>si vous êtiez déjà dans le dossier NAS lors du montage du dossier</u>, alors la commande ls ne vous renverra rien, il vous faudra revenir en arrière et retourner dedans.

Maintenant, nous allons faire en sorte que le dossier se monte <u>au démarrage du système</u>. Pour cela :

- On démonte le dossier actuellement monté :
  

```bash
sudo unmount /mnt/NAS
```

- On modifie ensuite le fichier fstab :
  

```bash
sudo nano /etc/fstab
```

- On ajoute à la fin du fichier la ligne suivante :
  

```bash
<ip nas>:/volumeX/votre_dossier /mnt/NAS nfs defaults,auto 0 0
```

- Voilà ce que donne le fichier **fstab** de mon côté (seul la dernière ligne est importante pour vous) :
  

```bash
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/sda2 during curtin installation
/dev/disk/by-uuid/6300fbcb-d404-4327-a645-fb1f9577d551 / ext4 defaults 0 1
# /mnt was on /dev/sdb1 during curtin installation
/dev/disk/by-uuid/7672cda1-b538-4243-8c9b-7c9ef90a032d /mnt ext4 defaults 0 1
/swap.img       none    swap    sw      0       0

192.168.1.105:/volume1/Media /mnt/NAS nfs defaults,auto 0 0
```

- On redémarre afin de vérifier que le dossier se monte bien au démarrage
  

```bash
sudo reboot
```

- Après redémarrage, on vérifie que le dossier se soit bien monté automatique en allant checker dedans :
  

```bash
cd /mnt/NAS
ls 
```

Normalement vous devriez voir vos dossiers et fichiers :)

## Docker et docker-compose

### Installation de docker et docker-compose

Il est maintenant temps d'utiliser la puissance de votre nouveau server avec **Docker**

- Commençons par installer **docker** et **docker-compose** :
  

```bash
sudo apt update && sudo apt install -y docker docker-compose
```

- On vérifie ensuite la bonne installation de **docker**
  

```bash
docker -v
```

La commande doit vous renvoyer quelque chose comme ça :

```bash
Docker version 20.10.12, build 20.10.12-0ubuntu4
```

Si la commande renvoie une erreur alors il y a eu un problème lors de l'installation

On peut ensuite lancer notre premier conteneur :

```bash
sudo docker run hello-world
```

Voici ce qu'elle doit renvoyer :

```bash
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

## Portainer

> [Portainer](https://www.portainer.io/) est une application web permettant de gérer les conteneurs d’une plateforme Docker et/ou Docker-Swarm.

### Installation

- Dans me dossier home de votre utilisateur, créez un dossier nommé portainer

```bash
cd #Pour retourner dans votre home
mkdir portainer
```

- Dans ce dossier, créez le fichier docker-compose.yaml

```bash
cd portainer
nano docker-compose.yaml
```

- Dans la fenêtre qui s'ouvre, copiez ces lignes :

```yaml
version: '3'

services:
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    environment:
      - TZ=Europe/Paris
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /docker/portainer:/data
    ports:
      - 9000:9000
```

- Appuyez ensuite sur CTRL + S puis CTRL + X pour enregistrer et quitter le fichier

Ici, le dossier data de portainer sera enregistré dans le dossier docker situé à la racine de votre serveur.

- Toujours dans le dossier **portainer**, lancez cette commande :

```bash
sudo docker-compose up -d
```

Si tout ce passe bien, portainer va s'installer. Pour vérifier qu'il fonctionne bien vous pouvez taper :

```bash
sudo docker ps
```

Voici ce que ça doit vous renvoyer :

```bash
CONTAINER ID   IMAGE                           COMMAND        CREATED          STATUS          PORTS                                                           NAMES
1fa97a25f95d   portainer/portainer-ce:latest   "/portainer"   58 seconds ago   Up 56 seconds   8000/tcp, 9443/tcp, 0.0.0.0:9000->9000/tcp, :::9000->9000/tcp   portainer
```

Maintenant que **Portainer** est installé, rendez-vous sur votre navigateur et taper l'adresse de votre serveur suivi du port 9000.

Pour moi se sera : http://192.168.1.210:9000

Vous devriez alors arriver sur la page de portainer

Une fois le compte créé, sur la page qui s'affiche cliquez sur **Get Started**

Cliquez ensuite sur **local**

Et voilà !

Il ne vous reste plus qu'à configurer vos conteneurs favoris. Voici un petit exemple pour la configuration actuelle, ici je vais prendre jellyfin :

- Dans portainer, aller dans **Stacks** > **Add stack**
  
- Donner un nom : jellyfin
  
- Copier le docker-compose ci-dessous :
  

```yaml
---
version: "2.1"
services:
  jellyfin:
    image: lscr.io/linuxserver/jellyfin
    container_name: jellyfin
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Paris
      #- JELLYFIN_PublishedServerUrl= #optional
    volumes:
      - /docker/jellyfin:/config
      - /volume1/mnt/NAS/Séries:/data/tvshows
      - /volume1/mnt/NAS/Films:/data/movies
    ports:
      - 8096:8096
```

Pour connaitre votre PUID/PGID :

```bash
id <votre utilisateur>
```

Ce qui donne pour moi :

```bash
guillaume@docker:~$ id guillaume
uid=1000(guillaume) gid=1000(guillaume) groups=1000(guillaume),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),110(lxd)
guillaume@stavnas:~$
```

Votre serveur est maintenant opérationnel et vous allez pouvoir utiliser la puissance de ce dernier avec les données contenues dans votre NAS Synology :)

Enjoy !
