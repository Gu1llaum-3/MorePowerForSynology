# More Power For Synology

> Le but de ce script est d'utiliser la puissance d'un autre ordinateur pour nos services à la place d'un NAS Synology n'ayant pas assez de puissance ou ne pouvant utiliser docker.

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

## Installation
Pour lancer l'installation :
```bash
git clone https://github.com/Gu1llaum-3/MorePowerForSynology.git
cd MorePowerForSynology
sudo install.sh
```

Pour monter un nouveau volume :
```bash
sudo mount_nfs.sh
```
