Pré-requis
==========

On dispose de trois noeuds sous Ubuntu Trusty à jour :

- ceph-node1 d'adresse IP 172.31.10.1
- ceph-node2 d'adresse IP 172.31.10.2
- ceph-node3 d'adresse IP 172.31.10.3

Chaque noeud doit pouvoir résoudre le hostname des
deux autres noeuds (on parle ici du nom court, pas
du fqdn).
Sur chaque noeud, on suppose qu'il y a un disque
**/dev/sdb** qui ne sert « à rien » (l'OS n'est pas
installé dessus). C'est sur ces disques dédiés
que le stockage des daemons osd sera effectué.
On supposera dans la suite les choses suivantes :

- Les disques sont **déjà** partitionnés avec simplement
**une seule partition** sur chaque disque (/dev/sdb1 donc);
- Les disques sont **déjà** formatés en **xfs** par exemple
via la commande `mkfs.xfs -f /dev/sdb1` (nécessite un éventuel
`apt-get install xfsprogs` avant).
- Aucune entrée dans /etc/fstab ne gère le montage de
ces disques `/dev/sdb`.

L'installation se fait sans l'infâme ceph-deploy qui,
en plus d'être anti-pédagogique, est pas mal buggé
(les développeurs de Ceph auraient mieux fait de
consacrer plus de temps pour écrire une doc d'installation
claire que de développer ce genre d'outil).




Installation de base à faire sur les trois noeuds
=================================================

Créer le script shell suivant, qu'on appellera ici
**install.sh**, sur chacun des trois noeuds :

```sh
#!/bin/sh

IP="$1"

# Installation du package Ceph.
URL='https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc'
CEPH_RELEASE="firefly"
wget -q -O- "$URL" | apt-key add -
echo "deb http://ceph.com/debian-$CEPH_RELEASE/ $(lsb_release -sc) main" \
    > "/etc/apt/sources.list.d/ceph.list"
apt-get update && apt-get install -y ceph

# Il faut que les noeuds du cluster soient bien à l'heure.
# Ici, je me contente de la configuration par défaut de ntp.
apt-get install -y ntp

# On modifie le fichier /etc/hosts afin que $(hostname)
# soit résolu en l'IP du noeud et pas en 127.0.1.1 comme
# c'est souvent le cas. Apparemment, ce point de détail
# est important pour Ceph.
sed -i "s/^127\.0\.1\.1/$IP/g" /etc/hosts
```

Il faut alors lancer ce script sur chacun des 3 noeuds
en indiquant en argument à chaque fois l'adresse IP du
noeud sur lequel le script est exécuté :

```sh
./install.sh "172.31.10.1" # sur ceph-node1
./install.sh "172.31.10.2" # sur ceph-node2
./install.sh "172.31.10.3" # sur ceph-node3
```




Création du premier daemon monitor sur ceph-node1
=================================================

Attention, cette phase est à effectuer sur ceph-node1
**uniquement** car la création du premier monitor (et
donc la création du cluster) est une démarche spécifique.
Sur ceph-node1, créer le script shell suivant qu'on
appellera ici **init_mon.sh** :


```sh
#!/bin/sh

# On choisit un nom pour son cluster.
cluster="$1"

# Chaque daemon dans un cluster Ceph possède un ID. Pour le
# monitor du noeud ceph-node1, on choisira naturellement
# l'ID 1 etc.
mon_id="$2"

# On génère automatiquement ce qui sera l'UUID du cluster
# qui est mis en place.
fsid="$(uuidgen)"

# Création du fichier de configuration de notre cluster Ceph.
# Ce fichier sera exactement le même sur les 3 noeuds.
cat > "/etc/ceph/$cluster.conf" <<EOF
[global]
    fsid                      = $fsid
    auth cluster required     = cephx
    auth service required     = cephx
    auth client required      = cephx
    osd journal size          = 1024
    filestore xattr use omap  = true
    osd pool default size     = 2
    osd pool default min size = 1
    osd pool default pg num   = 256
    osd pool default pgp num  = 256
    osd crush chooseleaf type = 1

[mon.1]
    host     = ceph-node1
    mon addr = 172.31.10.1

[mon.2]
    host     = ceph-node2
    mon addr = 172.31.10.2

[mon.3]
    host     = ceph-node3
    mon addr = 172.31.10.3

EOF

# On crée un fichier qui définit les droits des daemons
# monitor dans le cluster avec une même clé que se partageront
# tous les daemons monitors (pour s'authentifier entre eux
# comme appartenant bien au cluster).
ceph-authtool --create-keyring "/tmp/$cluster.mon.keyring" \
    --gen-key -n mon. --cap mon 'allow *'

# On crée dans la configuration du cluster Ceph les droits
# du compte client.admin au niveau du cluster. Ce compte
# est le compte utilisé par défaut par les outils de monitoring
# Ceph.
ceph-authtool --create-keyring "/etc/ceph/$cluster.client.admin.keyring" \
    --gen-key -n client.admin --set-uid=0                                \
    --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow'

# Cette commande ajoute simplement le contenu du fichier donné
# par l'option --import-keyring dans le fichier donné en argument.
ceph-authtool --import-keyring "/etc/ceph/$cluster.client.admin.keyring" \
     "/tmp/$cluster.mon.keyring"

# On génère une « monitor map » qui représente la topologie
# du cluster au niveau des monitors, sachant que la topologie
# actuelle du cluster va indiquer pour l'instant l'existence
# d'un daemon monitor d'ID 1 qui tourne sur ceph-node1 et c'est
# tout (le fichier généré est totalement inintelligible pour un
# humain).
monmaptool --create --add "$mon_id" "172.31.10.1" --fsid "$fsid" "/tmp/monmap"

# On initialise le répertoire de travail du monitor
# qui se trouve dans "/var/lib/ceph/mon/$cluster-$mon_id".
# Pour ce faire on fournit à la commande les éléments suivants :
#   - le fsid du cluster (à travers le fichier de conf);
#   - la clé secrète des monitors et celle du compte client.admin
#     (via le fichier /tmp/$cluster.mon.keyring);
#   - la monitor map de départ.
# La clé secrète du compte client.admin est une clé partagée
# entre les clients et les daemons monitors.
ceph-mon --mkfs -i "$mon_id" --conf "/etc/ceph/$cluster.conf"    \
    --monmap "/tmp/monmap" --keyring "/tmp/$cluster.mon.keyring" \
    --cluster "$cluster"

# On supprime les 2 fichiers temporaires qu'on a utilisés.
rm "/tmp/$cluster.mon.keyring"
rm "/tmp/monmap"

# Notre daemon monitor est prêt à être démarré mais avant,
# il faut ajouter ces 2 fichiers vides, sans quoi le daemon
# ne se lance tout simplement pas.
touch "/var/lib/ceph/mon/$cluster-$mon_id/done"
touch "/var/lib/ceph/mon/$cluster-$mon_id/upstart"

# On lance notre nouveau service. A prior le "stop" est
# inutile car le service n'existait pas avant. C'est juste
# au cas où.
stop ceph-mon cluster="$cluster" id="$mon_id"
sleep 0.5
start ceph-mon cluster="$cluster" id="$mon_id"

# Remarque : si l'on veut on peut redémarrer tous les services
# liés à Ceph avec quelque chose de radical comme ceci :
#
#       stop ceph-all
#       start ceph-all
```

Sur ceph-node1 donc, lancer le script ci-dessus de la
manière suivante :

```sh
./init_mon.sh ceph 1 # script à lancer sur ceph-node1 uniquement
```

où **ceph** sera donc le nom de notre cluster et **1** sera
l'ID du daemon monitor sur ceph-node1. Normalement, on doit
avoir un daemon ceph-mon qui tourne. On peut le vérifier avec :

```sh
ps aux | grep cep[h]
```

Pour l'instant, sur ceph-node1, on peut tenter de voir
l'état de notre cluster avec :

```sh
ceph status --cluster=ceph -m ceph-node1
```

Mais ça ne sera pas très concluant car pour l'instant
on a juste un monitor tout seul et rien pour gérer le
stockage des objets car aucun daemon osd n'est en place.

**Remarque :** dans un cluster en bonne santé (et donc
pas un cluster naissant comme le notre), on peut
omettre l'option -m dans la commande. Cette option
indique le monitor qu'on souhaite contacter pour connaitre
l'état du cluster. Si on ne précise pas cette option, la
commande va tenter de contacter un des monitors indiqués
dans le fichier `/etc/ceph/$cluster.conf` et passera à un
autre si ça ne fonctionne pas. Dans notre cas, un seul
monitor sur trois est en place et donc, sans l'option, la
commande aura des latences car deux fois sur trois elle
contactera un monitor qui ne répondra pas (encore).




Déploiement de la configuration Ceph sur les deux autres noeuds
===============================================================

La configuration Ceph doit être la même sur les trois noeuds,
alors on copie cette configuration **de** ceph-node1 **vers**
ceph-node2 et ceph-node3 avec un simple scp :

```sh
# On reprend le nom de notre cluster.
cluster="ceph"

# Ici on envoie /etc/ceph/$cluster.conf (indispensable) et aussi
# /etc/ceph/$cluster.client.admin.keyring. Ce dernier n'est pas
# obligatoire mais il est nécessaire si l'on souhaite pouvoir
# monitorer notre cluster Ceph sur n'importe lequel des noeuds.
scp "/etc/ceph/$cluster."* ceph-node2:/etc/ceph/
scp "/etc/ceph/$cluster."* ceph-node3:/etc/ceph/
```




Installation des autres daemons monitor sur ceph-node2 et ceph-node3
====================================================================

La procédure pour **ajouter** un monitor au sein du cluster
(qui contient donc déjà au moins un monitor)
est la même à chaque fois. Il faut donc copier le script
ci-dessous sur ceph-node2 et ceph-node3. On appellera
**add_mon.sh** ce script :

```sh
#!/bin/sh

# Le nom du cluster.
cluster="$1"

# ID du daemon monitor à créer.
mon_id="$2"

# C'est l'IP de ceph-node1, le monitor qu'on va devoir
# contacter pour créer notre nouveau monitor sur ceph-nod2
# et l'intégrer au cluster. En effet, à ce stade, le
# monitor de ceph-node1 est le seul monitor du cluster que
# l'on puisse contacter.
IP_MON=172.31.10.1

# On récupère la clé secrète partagée par tous les
# daemons monitors en contactant le monitor de ceph-node1.
# On peut le faire car on utilise le compte client.admin
# (compte par défaut) et qu'on a importé sa conf sur
# ceph-node2 précédemment.
ceph auth get mon. -o "/tmp/$cluster.mon.keyring" \
    -m ceph-node1 --cluster "$cluster"

# On récupère également la monitor map auprès de notre cluster
# afin de pouvoir initialiser le répertoire de travail du monitor
# de ceph-node2.
ceph mon getmap -o "/tmp/monmap" -m "$IP_MON" --cluster "$cluster"

# On crée et on initialise le répertoire de travail du daemon
# monitor qui se trouve dans "/var/lib/ceph/mon/$cluster-$mon_id".
ceph-mon --mkfs -i "$mon_id" --conf "/etc/ceph/$cluster.conf"    \
    --monmap "/tmp/monmap" --keyring "/tmp/$cluster.mon.keyring" \
    --cluster "$cluster"

# On supprime les 2 fichiers temporaires qu'on a utilisés.
rm "/tmp/$cluster.mon.keyring"
rm "/tmp/monmap"

# Notre daemon monitor est prêt à être démarré mais avant,
# il faut ajouter ces 2 fichiers vides, sans quoi le daemon
# ne se lance tout simplement pas.
touch "/var/lib/ceph/mon/$cluster-$mon_id/done"
touch "/var/lib/ceph/mon/$cluster-$mon_id/upstart"

# On lance notre daemon monitor.
stop ceph-mon cluster="$cluster" id="$mon_id"
sleep 0.5
start ceph-mon cluster="$cluster" id="$mon_id"

# Remarque : on peut aussi relancer tous les services
# monitor avec :
#
#       stop ceph-mon-all
#       start ceph-mon-all
```

Sur ceph-node2 et ceph-node3, on lance donc les commandes
suivantes :

```sh
# On crée deux nouveaux monitors appartenant au cluster "ceph"
# et d'ID 2 sur ceph-node2 et d'ID 3 sur ceph-node3.
./add_mon.sh ceph 2 # sur ceph-node2
./add_mon.sh ceph 3 # sur ceph-node3
```

Là aussi, on doit voir un daemon ceph-mon tourner sur les
noeuds 2 et 3 via la commande :

```sh
ps aux | grep cep[h]
```

Et en principe, on peut faire un `ceph status` sur n'importe
quel noeud sans préciser cette fois le monitor à contacter :

```sh
# Ceci doit alors marcher sur n'importe quel noeud.
ceph status --cluster=ceph
```

Au niveau de la ligne **monmap**, on doit voir les trois
monitors présents dans le cluster.
À ce stade, on a trois daemons monitor qui tournent sur chacun
des trois noeuds mais aucun daemon osd, donc pour l'instant
notre cluster ne gère aucun stockage.




Installation des daemons osd sur chacun des trois noeuds
========================================================

On retourne sur ceph-node1 pour y installer notre
premier daemon osd. Attention, le disque **/dev/sdb**,
est censé être formaté en xfs avec une seule partition
**/dev/sdb1** (le disque est censé être vide, sinon le
formater avec `mkfs.xfs -f /dev/sdb1`). Voici le
script que l'on lancera sur chacun des trois noeuds.
On appellera ce script **add_osd.sh** :


```sh
#!/bin/sh

# Le nom du cluster qui sera donné en argument du script.
cluster="$1"

# Chaque osd possède son propre uuid. On en génère
# un automatiquement.
uuid=$(uuidgen)

# Création/déclaration d'un osd dans le cluster.
# TODO
# Là, je n'ai pas encore trouvé comment imposer un ID
# pour le daemon osd. Du coup, l'ID est choisi par le
# cluster ce qui va faire que ceph-node1 possèdera
# l'osd ayant pour id 0, ceph-node2 pour id 1 et ceph-node3
# pour id 2. C'est un peu nul...
# En fait, j'ai posé la question sur la liste ceph-users,
# et Loïc Dachary m'a répondu qu'il valait mieux
# laisser le cluster choisir les ID des osds, sans
# toutefois me dire si c'était possible ou non de les
# choisir soi-même.
osd_id=$(ceph --cluster "$cluster" osd create "$uuid")
printf "The id of this osd will be $osd_id.\n"

# On crée le répertoire de travail du daemon osd.
# C'est ce répertoire qui contiendra le stockage
# des objets. Il ne faudra pas espérer retrouver
# une arborescence intelligible des fichiers dans
# ce répertoire.
# C'est donc sur ce répertoire qu'on va monter notre
# partition /dev/sdb1 dédiée.
mkdir "/var/lib/ceph/osd/$cluster-$osd_id/"
mount -t xfs /dev/sdb1 "/var/lib/ceph/osd/$cluster-$osd_id/"

# On initialise de le contenu du répertoire de travail
# de notre daemon osd. L'option --mkkey permet de générer
# le keyring associé à ce daemon osd, le fsid du cluster
# et la liste des monitors sont fournis dans le fichier
# $cluster.conf.
# Je fais un >/dev/null car la commande affiche des messages
# qui laissent penser qu'il y a des erreurs alors que ce n'est
# pas le cas.
ceph-osd -i "$osd_id" --mkfs --mkkey --cluster "$cluster" \
    --conf "/etc/ceph/$cluster.conf" --osd-uuid "$uuid" >/dev/null 2>&1

# On enregistre le keyring de notre osd auprès du cluster.
ceph auth add "osd.$osd_id" osd 'allow *' mon 'allow profile osd' \
    -i "/var/lib/ceph/osd/$cluster-$osd_id/keyring"               \
    --cluster "$cluster" --conf "/etc/ceph/$cluster.conf"

# On ajoute le noeud courant dans la CRUSH map. Ce n'est pas
# encore très clair pour moi cette notion mais en gros on
# indique au cluster l'existence d'un nouvel hôte (l'hôte
# courant sur lequel on exécute ces commandes) conteneur de
# service(s) osd(s). La CRUSH map correspond à la topologie
# des osds au sein du cluster.
# Cette commande est idempotente, on peut la répéter autant
# de fois que l'on veut. À partir de la deuxième exécution,
# la commande affiche un message indiquant que le noeud se
# trouve déjà dans la CRUSH map et la commande retourne la
# valeur 0.
ceph osd crush add-bucket $(hostname) host --cluster "$cluster"

# On place le noeud correspondant à l'hôte courant au niveau
# de la racine "default" du cluster. Si jamais on ajoute
# plusieurs osds sur un même noeud, on peut répéter cette
# commande autant de fois que l'on veut ce n'est pas grave.
# À partir de la deuxième fois, la commande affichera
# simplement un message disant que le noeud se trouve déjà
# dans la racine "default" du cluster et renverra 0 comme
# exit code.
ceph osd crush move $(hostname) root=default --cluster "$cluster"

# On déclare notre osd dans la CRUSH map avec le poids 1.0.
ceph osd crush add "osd.$osd_id" 1.0 host=$(hostname) --cluster "$cluster"

# Pour que le daemon osd-$osd_id démarre à chaque boot.
touch "/var/lib/ceph/osd/$cluster-$osd_id/ready"
touch "/var/lib/ceph/osd/$cluster-$osd_id/upstart"

# Démarrage de notre service osd.
stop ceph-osd cluster="$cluster" id="$osd_id"
sleep 0.5
start ceph-osd cluster="$cluster" id="$osd_id"

# Remarque : on peut relancer tous les services osd avec :
#
#       stop ceph-osd-all
#       start ceph-osd-all

# Il ne faut pas oublier de modifier fstab afin que notre
# disque soit bien monté au démarrage du système.
# Déjà, on récupère l'UUID de la partition.
#
# En fait, il y a quand plus simple et plus élégant que ça :
#
# eval $(blkid | grep ^/dev/sdb1 | sed -r 's/.*(UUID=[^ ]*).*/\1/')
#
# On utilise plutôt l'option "-o export" de la commande blkid :
eval $(blkid -o export /dev/sdb1)

# Modification du fichier fstab.
printf "Update of /etc/fstab\n"
printf "\n# OSD storage.\n" >> /etc/fstab
printf "UUID=$UUID /var/lib/ceph/osd/$cluster-$osd_id/ xfs defaults,noatime 0 2\n\n" \
    >> /etc/fstab

# Enfin pour être sûr que notre point de montage dans
# /etc/fstab est correct et pour appliquer les options de
# montage qu'on a indiquées dans ce fichier /etc/fstab, on
# fait un remount.
mount -o remount "/var/lib/ceph/osd/$cluster-$osd_id/"

# On pourra alors vérifier notamment que l'option de
# montage noatime est bien appliquée avec :
#
#   mount | grep "/var/lib/ceph/osd/$cluster-$osd_id"
```

On lance alors le script ci-dessus sur chacun des trois
noeuds de la manière suivante :

```sh
# C'est le même appel sur chacun des trois noeuds où l'ID
# de l'osd créé sera choisi par le cluster. En argument,
# on indique juste le nom du cluster.
./add_osd.sh ceph
```

À ce stade, on peut vérifier avec :

```sh
ps aux | grep cep[h]
ceph status --cluster=ceph
```

qu'un processus ceph-osd tourne bien sur chaque  machine
et que notre osd est bien présent au niveau du cluster
(voir la ligne **osdmap** affichée par la deuxième
commande).

En principe, juste après la création d'un osd sur ceph-node1
l'état du cluster n'est pas ok :

```
health HEALTH_WARN 192 pgs degraded;
```

En effet, le cluster doit stocker les objets en
deux exemplaires car les données sont répliquées (le
nombre de réplications est paramétrable). Or avec
un seul osd ce n'est pas possible. Il faut ajouter
un nouvel osd, au moins. Il faudra donc attendre la
création du deuxième osd sur ceph-node2 pour avoir
un cluster 100% ok. Normalement, quelques minutes
(voire quelques secondes) après l'installation
du deuxième osd sur ceph-node2, la santé du cluster
sera ok (car il pourra satisfaire la contrainte sur
le nombre de réplications).

Une fois tous les osds installés sur chacun des noeuds,
on possède un cluster Ceph opérationnel qui peut offrir du
**RADOS block device** (on écrit plus simplement **rbd**)
à des machines clientes. En revanche, le CephFS (qui est un
file system "cluster aware", ie qu'on peut monter simultanément
sur plusieurs noeuds clients en lecture et écriture) n'est pas
encore fourni par notre cluster car il faudra au préalable
installer le daemon mds supplémentaire (voir plus loin).




Lister les pools du cluster
===========================

Si on compare un cluster Ceph à une sorte de gros disque
accessible par le réseau, alors les pools correspondent
au partition de ce disque. Sur un des noeuds du cluster,
pour lister les pools, on lance la commande suivante :

```sh
ceph osd lspools --cluster "$cluster"

```

Par défaut on a les pools `data`, `metadata` et `rbd`.
Le pool `rbd` est dédié aux "rados block devices" (qu'on appelle
plus simplement des rbd justement), tandis que les pools `data` et
`metadata` sont utilisés pour fournir le CephFS (un pour stocker
les données proprement dites du CephFS et l'autre pour stocker
les métadonnées du CephFS comme les droits etc). D'après ce que
j'ai compris, les pools `data` et `metadata` dédiés au CephFS
sont particuliers et ne servent qu'à cela. Un cluster Ceph (pour
la version actuelle de Ceph, ie Firefly) ne peut fournir qu'un
seul CephFS. Si on crée soi-même un nouveau pool, il pourra
accueillir des rbd mais pas de CephFS.

Pour créer des images rbd, on peut aller au plus simple et
utiliser le pool `rbd` qui est fait pour ça. Pour des raisons
pédagogiques, on va se créer un pool `pooltest` et c'est dans
celui-là qu'on va créer une image rbd :

```sh
# Création d'un pool ayant pour nom "pooltest" et
# possédant 256 "placement groups".
ceph osd pool create pooltest 256 --cluster "$cluster"
```




Utilisation d'un RADOS block device (rbd) sur un client
=======================================================

Comme à ce stade le cluster peut offrir du rbd, on va
tester d'en créer un et de l'utiliser sur un client.
Pour l'instant, les manipulations sont à faire sur un
des noeuds du cluster (peu importe lequel).
Pour lister les images rbd qui se trouvent dans le pool
`pooltest`, lancer la commande suivante :

```sh
# Les options -c et --id sont en fait inutiles dans la
# commande ci-dessous car les valeurs indiquées sont les
# valeurs par défaut.
rbd ls --pool pooltest --cluster "$cluster" \
    -c "/etc/ceph/$cluster.conf" --id admin
```

Évidemment, pour l'instant aucune image rbd n'existe
dans ce pool. On crée alors une image rbd :

```sh
# Crée une image rbd qui s'appellera "rbdtest" dans le pool pooltest.
# La taille est en MB (ici on crée un « petit » rbd)
rbd create rbdtest --pool pooltest --size 1024 --cluster "$cluster"

# On vérifie que l'image rbd est bien créée.
rbd ls --pool pooltest --cluster "$cluster"
```

Un client doit toujours s'authentifier pour accéder à
une ressource du cluster et cela se fait via une clé
partagée entre le serveur et le client. Le client sera
possesseur d'une clé associée à un compte C du cluster et
cette clé lui permettra de s'authentifier auprès du cluster
comme étant le compte C. Évidemment, on pourrait utiliser
la clé du compte `client.admin` mais c'est une mauvaise
pratique car ce compte est le compte administrateur du
cluster (il peut tout faire) et sa clé ne devrait pas en
principe se trouver ailleurs que dans les noeuds du cluster.

On va donc créé un compte `client.pooltest` qui va pouvoir
accéder aux images rbd du pool `pooltest` et qui va pouvoir
mapper et démapper une image rbd du pool `pooltest` etc. :

```sh
ceph auth --cluster "$cluster" get-or-create client.pooltest \
    mon 'allow r'                                            \
    osd "allow class-read object_prefix rbd_children"        \
    osd "allow rwx pool=pooltest"

# On exporte le fichier de keyring associé à ce compte Ceph
# en interrogeant le cluster. Le fichier créé ne sert pas
# à grand chose sur un des noeuds du cluster. En revanche,
# il faudra le copier sur le client qui va utiliser ce
# compte Ceph.
ceph auth --cluster "$cluster" get client.pooltest \
    > "/etc/ceph/$cluster.client.pooltest.keyring"

# On ajuste les droits sur ce fichier qui contient la clé
# associée à ce compte.
chmod 600 "/etc/ceph/$cluster.client.pooltest.keyring"
```

Au niveau du cluster, tout est en place. Maintenant on se
rend sur le client pour installer le nécessaire, récupérer
le fichier de keyring associé au compte `client.pooltest` puis
mapper l'image rbd :

```sh
# On installe le paquet ceph-common car on a besoin de
# la commande rbd pour mapper et démapper une image rbd.
URL='https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc'
CEPH_RELEASE="firefly"
wget -q -O- "$URL" | apt-key add -
echo "deb http://ceph.com/debian-$CEPH_RELEASE/ $(lsb_release -sc) main" \
    > "/etc/apt/sources.list.d/ceph.list"
apt-get update
apt-get install -y ceph-common

# Ensuite, on copie le fichier de conf du cluster qui
# se trouve sur un des noeuds ainsi que le fichier de keyring
# du compte client.pooltest car le client doit forcément connaître
# la clé associée à ce compte pour s'authentifier auprès du
# cluster.
scp ceph-node1:"/etc/ceph/$cluster.conf" /etc/ceph/
scp ceph-node1:"/etc/ceph/$cluster.client.pooltest.keyring" /etc/ceph/

# Désormais avec ce compte client.pooltest, notre machine cliente
# va pouvoir mapper/démapper une image rbd existante dans le pool
# pooltest.
# L'option --id indique le compte qu'on utilise pour mapper l'image
# rbdtest. Ici on utilise donc le compte client.pooltest mais on
# enlève la partie « client. » dans la valeur de l'option --id.
rbd map rbdtest --pool pooltest --cluster "$cluster" --id pooltest
```

Maintenant, sur la machine cliente, on dispose d'un block
device `/dev/rbd/pooltest/rbdtest` qu'on peut utiliser comme n'importe
quel block device : on peut le partitionner, le formater avec
le file system de son choix, le monter, le démonter etc. On peut
parfaitement mapper et monter ce block device sur deux clients
différents mais alors dans ce cas il faut utiliser dans ce block
device un file system "cluster-aware".

**Remarque :** le nom du block device est toujours de la forme :

```
/dev/rbd/<nom-du-pool>/<nom-de-l-image-rbd>
```

Mais en fait, ce fichier est un lien symbolique vers le véritable
block device dont le nom est de la forme `/dev/rbdN` avec N un
entier qui est incrémenté à chaque nouveau block device mappé.

Si on n'a plus besoin de cette image rbd sur le client, on
peut alors démapper le block device (à condition que celui-ci
ne soit plus utilisé par le client bien sûr) :

```sh
rbd unmap "/dev/rbd/pooltest/rbdtest" --cluster "$cluster" --id pooltest
```

À ce moment là, les données qui se trouvent dans l'image rbd
`rbdtest` existent toujours, l'image rbd existe toujours et
peut parfaitement être réutilisé plus tard par la machine
cliente (ou par une autre machine cliente si elle en a les
droits). Si on veut carrément détruire l'image `rbdtest`
du pool `pooltest`, on peut le faire sur la machine cliente
avec :

```sh
rbd rm rbdtest --pool pooltest --cluster $cluster --id pooltest
```

Mais attention, une fois que c'est fait, les données contenues
dans l'image `rbdtest` sont définitivement perdues.

**Remarque :** le compte Ceph `client.pooltest` a le droit de
vie et de mort sur les images rbd appartenant au pool `pooltest`
mais pas sur les autres pools du cluster.




Création d'un service mds sur chaque noeud du cluster
=====================================================

Le service mds (MetaData Server) est indispensable si
l'on veut que le cluster fournisse du CephFS.

**Remarque :** attention, avec la version actuelle de Ceph
(Firefly), CephFS n'est pas production ready (lu sur IRC
« si tu utilises CephFS, vérifie bien tes backups). La technologie
rbd, quant à elle, est considérée comme production ready.

On va installer ce daemon sur chacun des trois noeuds du
cluster. Voici le script à placer sur les trois
noeuds. On l'appellera **add_mds.sh** :

```sh
#!/bin/sh

cluster="$1"
mds_id="$2"

# Création du répertoire de travail du daemon mds.
mkdir "/var/lib/ceph/mds/$cluster-$mds_id"

# Création d'un compte "mds-$mds_id" avec les droits
# nécessaires pour un daemon mds. La clé générée est
# stockée dans /var/lib/ceph/mds/$cluster-$mds_id/keyring
# pour que le service mds connaisse sa clé pour s'authentifier
# au niveau du cluster.
ceph --cluster "$cluster" auth get-or-create "mds.$mds_id" \
    mds "allow" osd "allow rwx" mon "allow profile mds"    \
    -o "/var/lib/ceph/mds/$cluster-$mds_id/keyring"

# Dans la commande ci-dessus, on se connecte par défaut
# avec le compte client.admin et donc par défaut on a les
# options suivantes :
#
#   --name client.admin
#   --keyring /etc/ceph/$cluster.client.admin.keyring
#
# Mais en fait on peut utiliser le keyring suivant, ça
# marche aussi (c'est le keyring utilisé par ceph-deploy
# pour installer un mds) :
#
#   --name client.bootstrap-mds
#   --keyring /var/lib/ceph/bootstrap-mds/$cluster.keyring

# Pour que le service mds démarre au boot du système.
touch "/var/lib/ceph/mds/$cluster-$mds_id/done"
touch "/var/lib/ceph/mds/$cluster-$mds_id/upstart"

if ! dpkg -l ceph-mds | grep -q '^ii'
then
    # Si ceph-mds n'est pas installé, son installation
    # déclenchera le démarrage du service mds.
    apt-get install -y ceph-mds
else
    # Sinon on redémarre le service mds.
    restart ceph-mds-all
fi
```

Sur les trois noeuds, on lance respectivement les
commandes suivantes :

```sh
# Le premier argument est le nom du cluster et le deuxième
# est l'ID que l'on attribue au service mds.
./add_mds.sh ceph 1 # sur ceph-node1
./add_mds.sh ceph 2 # sur ceph-node2
./add_mds.sh ceph 3 # sur ceph-node3
```

On a alors un service mds fourni par le cluster mais il
n'est pas vraiment hautement disponible dans le sens où
il peut (hélas) avoir une interruption de service. En effet,
comme on peut le voir avec `ceph status`, on a une ligne
de ce genre là :

```
mdsmap e6: 1/1/1 up {0=1=up:active}, 2 up:standby
```

Cela signifie que, contrairement aux osds qui sont tous
actifs en même temps, il y a toujours un seul mds actif
et les autres sont en standby. Donc, si jamais le mds
actif tombe, le service CephFS offert par le cluster
sera interrompu pendant quelques secondes (entre 30 et
60 secondes d'après mes tests) jusqu'à ce qu'un des mds
en standby reprenne la main.

On va maintenant créer un compte Ceph `client.mountcephfs`
qui aura suffisamment de droits pour monter et écrire sur le
CephFS. La manipulation est à faire sur un des noeuds du
cluster :

```sh
# TODO: je ne suis pas sûr du tout des droits.
# Je constate que ça permet le montage du CephFS
# sur un client mais peut-être que ces droits sont
# élevés plus que nécessaire, je ne sais pas.
ceph --cluster "$cluster" auth get-or-create client.mountcephfs \
    mon 'allow r'                                               \
    osd "allow class-read object_prefix rbd_children"           \
    osd "allow rwx pool=data, allow rwx pool=metadata"

# On peut vérifier que notre compte est bien créé avec :
ceph --cluster "$cluster" auth get client.mountcephfs
```

Il faut alors noter dans un coin le champ key associé
au compte car on va en avoir besoin côté client. En
effet, sur le client on effectue les commandes suivantes :

```sh
# On a juste besoin du paquet ceph-fs-common.
URL='https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc'
CEPH_RELEASE="firefly"
wget -q -O- "$URL" | apt-key add -
echo "deb http://ceph.com/debian-$CEPH_RELEASE/ $(lsb_release -sc) main" \
    > "/etc/apt/sources.list.d/ceph.list"
    apt-get update && apt-get install -y ceph-fs-common

# Ensuite la clé associée au compte "mountcephfs" est
# placée dans un fichier (juste la valeur de la clé)
# que seul root pourra lire :
echo "$key" > "/etc/ceph/$cluster.client.mountcephfs.key"
chmod 400 "/etc/ceph/$cluster.client.mountcephfs.key"

# Et on peut alors monter le cephFS. Les noms d'hôtes indiqués
# ci-dessous sont les noms des monitors. Il est sans doute
# préférable d'indiquer des IP.
# Dans les options de montage, on précise le nom du compte
# (sans la partie « client. ») et le secretfile qui contient
# la clé de ce compte. On peut aussi utiliser l'option
# "secret" au lieu de "secretfile" et indiquer alors directement
# la clé comme valeur, ie « secret=kRFRAA0R6mOS0EYUxg0FHw== ».
# Mais c'est à éviter car la clé apparaît alors dans l'historique
# du shell.
mount -t ceph ceph-node1,ceph-node2,ceph-node3:6789:/ /mnt \
    -o name=mountcepfs,secretfile="/etc/ceph/$cluster.client.mountcephfs.key"
```

Et voilà, le CephFS est accessible en lecture et en écriture
via le répertoire `/mnt` du client. Au passage, si jamais par
exemple un répertoire `/client` a été créé au préalable dans
le CephFS, alors il est tout à fait possible de monter le
répertoire `/mnt` du client directement au niveau du répertoire
`/client` du CephFS avec :

```sh
mount -t ceph ceph-node1,ceph-node2,ceph-node3:6789:/client /mnt \
    -o name=mountcepfs,secretfile="/etc/ceph/$cluster.client.mountcephfs.key"
```

Sur le client, lors qu'on visitera alors le répertoire `/mnt`,
on visitera en réalité le contenu du répertoire `/client` du
CephFS et ne pourra alors avoir accès sur le client à tout ce
qu'il y a « au dessus » de ce répertoire `/client`.
Enfin, on rappelle que ce file system est cluster-aware et qu'on
peut donc le monter en lecture et en écriture sur plusieurs
clients.

Pour démonter le répertoire, on fait comme d'habitude avec :

```sh
umount /mnt
```

Il faut bien sûr que le montage ne soit plus sollicité par des
processus (et en particulier cela ne peut pas marcher si, dans
son shell courant, on se trouve dans /mnt au moment du umount).



La suite n'est pas achevée
==========================


Sortir un osd du cluster Ceph
=============================


```sh
# http://ceph.com/docs/master/rados/operations/add-or-rm-osds/#removing-osds-manual

# Sort le osd du cluster, afin qu'il passe à out proprement
# et que le cluster fasse le rebalancing des données si nécessaire.
ceph osd out $osd_id

# Il faut stopper le service associé à l'osd.
/etc/init.d/ceph stop osd.$osd_id

ceph osd crush remove osd.0

# (pas fini...)
```




Installer un Ceph object gateway
================================

Un tel service peut s'installer sur un serveur distinct des
nœuds du cluster Ceph. Sur un document de la société inktank,
on peut lire à propos d'une rados gateway la définition suivante :

```
It's a stateless web application which provides S3 or
Swift API access to data stored on the Ceph OSDs.
```
Ici, on va installer une rados gateway sur une Ubuntu Trusty
qui n'est pas un des nœuds du cluster (même si a priori
l'installation doit pouvoir se faire aussi sur un nœud du
cluster). Du point de vue du cluster Ceph, une rados gateway
est un simple client Ceph.

Pour commencer, on installe les paquets nécessaires :

```sh
# Mise à jour des dépôts pour pouvoir installer une
# version d'Apache2 légèrement optimisée dans le support
# des réponses http de type « 100-continue » (je ne sais
# pas ce que c'est).
url="https://raw.github.com/ceph/ceph/master/keys/autobuild.asc"
wget -q -O- "$url" | apt-key add -
distrib=$(lsb_release -sc)

url="http://gitbuilder.ceph.com/apache2-deb-$distrib-x86_64-basic/ref/master"
echo deb $url $distrib main > /etc/apt/sources.list.d/ceph-apache.list

url="http://gitbuilder.ceph.com/libapache-mod-fastcgi-deb-$distrib-x86_64-basic/ref/master"
echo deb $url $distrib main > /etc/apt/sources.list.d/ceph-fastcgi.list

apt-get update && apt-get install -y apache2 libapache2-mod-fastcgi
```

Ensuite on configure Apache et FastCGI :

```sh
echo ServerName $(hostname -f) > /etc/apache2/conf-available/ceph.conf
a2enconf ceph.conf
a2enmod rewrite
a2enmod fastcgi
service apache2 restart
```

Et enfin l'installation du paquet fournissant le service
`radosgw` (RADOS Gateway) :

```sh
# Il faut récupérer la version packagée par ceph.
URL='https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc'
CEPH_RELEASE="firefly"
wget -q -O- "$URL" | apt-key add -
echo "deb http://ceph.com/debian-$CEPH_RELEASE/ $(lsb_release -sc) main" \
    > "/etc/apt/sources.list.d/ceph.list"
apt-get update
apt-get install radosgw ceph

# Rq: l'installation du paquet radosgw suffit presque.
#     Sans l'installation du paquet ceph, le seul problème
#     qu'on a c'est que le daemon radosgw ne démarre pas
#     automatiquement à chaque boot. En effet, dans la
#     conf upstart, le service radosgw dépend au final
#     du service ceph-all. Or celui-ci se trouve dans le
#     paquet ceph. Du coup, si le paquet ceph n'est pas
#     installé, le service radosgw ne démarre pas automatiquement
#     lors d'un reboot.


# Si jamais on souhaite une architecture dite "federated", il
# faut aussi installer le paquet `radosgw-agent`. C'est un agent
# qui permet la synchronisation des data et des métadata entre
# des stockage ceph répartis sur plusieurs zones et régions.
# Ici, on va se contenter d'une installation la plus simple
# possible, donc pas "federated".
#apt-get install radosgw-agent
```

Maintenant, sur un des noeuds du cluster, on crée un compte
ceph pour notre rados gateway qui n'est rien d'autre qu'un client ceph :

```sh
# Création d'un fichier de keyring pour le compte ceph `radosgw`.
# En fait la commande ci-dessous revient globalement à un simple touch.
ceph-authtool --create-keyring /etc/ceph/ceph.client.radosgw.keyring

# En fait, ce fichier ne sert pas forcément sur un nœud du cluster.
# En revanche il devra se trouver sur le client ceph radosgw. Le
# service radosgw tourne sous root donc a priori seul root a besoin
# de pouvoir lire ce fichier.
chown root:root /etc/ceph/ceph.client.radosgw.keyring
chmod 0600      /etc/ceph/ceph.client.radosgw.keyring

# On génère une clé pour notre instance radosgw.
ceph-authtool /etc/ceph/ceph.client.radosgw.keyring \
    -n client.radosgw.gateway --gen-key

# On ajoute des capabilities du compte ceph dans le fichier.
# Voir sur cette page
#
#   http://docs.ceph.com/docs/master/radosgw/config/#create-a-user-and-keyring
#
# la remarque à propos des capabilities au niveau des monitors.
# Ici, je décide de mettre le droit 'w' sur les monitors.
# TODO: voir si on ne peut pas mettre des droits plus limités (sur
#       un seul pool par exemple) car là il me semble que le compte
#       radosgw.gateway est pas loin d'avoir les droits de l'admin.
ceph-authtool -n client.radosgw.gateway --cap osd 'allow rwx' \
    --cap mon 'allow rwx' /etc/ceph/ceph.client.radosgw.keyring

# Maintenant qu'on a notre fichier de keyring qui définit notre compte
# ceph `radosgw`, on va ajouter l'ajouter dans le cluster :
ceph -k /etc/ceph/ceph.client.admin.keyring auth add client.radosgw.gateway \
    -i /etc/ceph/ceph.client.radosgw.keyring

# Il faut ensuite copier le fichier /etc/ceph/ceph.client.radosgw.keyring pour
# qu'il soit présent sur l'hôte radosgw, car c'est lui le client ceph, il a
# donc besoin de ce fichier.
scp /etc/ceph/ceph.client.radosgw.keyring ceph-radosgw:/etc/ceph/
```

Ensuite, il faut modifier le fichier de configuration de ceph
du cluster afin de lui ajouter une section concernant le radosgw.
Il faut ajouter ceci dans le fichier de configuration :

```sh
cluster=ceph    # À adapter suivant le nom du cluster ceph.
host=ceph-node4 # À adapter suivant le nom d'hôte qui joue le rôle de radosgw.
radosgw_id=radosgw.gateway

# La dernière ligne "rgw dns name" semble très importante.
# Un début d'explication ici :
#
#   http://docs.ceph.com/docs/master/radosgw/config/#enabling-subdomain-s3-calls
#
cat >> "/etc/ceph/$cluster.conf" <<EOF
[client.$radosgw_id]
host            = $host

# TODO: cette ligne est-elle nécessaire ? À tester.
#       Elle casse le comportement par défaut des commandes
#       ceph qui est assez pratique et qui consiste à chercher
#       par défault le fichier keyring dans /etc/ceph/$cluster.$name.keyring
#       lors d'un appel du type "ceph --name $name --cluster $cluster.
keyring         = /etc/ceph/ceph.client.radosgw.keyring

rgw socket path = /var/run/ceph/ceph.$radosgw_id.fastcgi.sock
log file        = /var/log/radosgw/client.$radosgw_id.log
rgw dns name    = $host

EOF
```
Une fois que ceci est fait sur un des noeuds du cluster, il faut copier
le fichier de configuration du cluster sur tous les autres noeuds à
l'identique.

Sur le serveur radosgw, il faut créer un gateway script :

```sh
cat >/var/www/s3gw.fcgi <<EOF
#!/bin/sh

exec /usr/bin/radosgw -c /etc/ceph/ceph.conf -n client.radosgw.gateway

EOF

chown www-data: /var/www/s3gw.fcgi
chmod +x /var/www/s3gw.fcgi
```

Toujours sur le serveur radosgw, on crée le répertoire de travail du
service :

```sh
radosgw_id=radosgw.gateway

mkdir -p "/var/lib/ceph/radosgw/$cluster-$radosgw_id"

# Nécessaire pour le démarrage du service.
touch "/var/lib/ceph/radosgw/$cluster-$radosgw_id/done"
```

Ensuite, on crée le fichier de configuration du vhost apache via :

```sh
mail=admin@domain.tld

cat >/etc/apache2/sites-available/rgw.conf <<EOF
FastCgiExternalServer /var/www/s3gw.fcgi -socket /var/run/ceph/ceph.radosgw.gateway.fastcgi.sock

<VirtualHost *:80>

    ServerName $(hostname -f)
    ServerAlias *.$(hostname -f)
    ServerAdmin $mail
    DocumentRoot /var/www
    RewriteEngine On
    RewriteRule  ^/(.*) /s3gw.fcgi?%{QUERY_STRING} [E=HTTP_AUTHORIZATION:%{HTTP:Authorization},L]

    <IfModule mod_fastcgi.c>
    <Directory /var/www>
            Options +ExecCGI
            AllowOverride All
            SetHandler fastcgi-script
            Order allow,deny
            Allow from all
            AuthBasicAuthoritative Off
        </Directory>
    </IfModule>

    AllowEncodedSlashes On
    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined
    ServerSignature Off

</VirtualHost>
EOF


a2ensite rgw.conf
a2dissite 000-default.conf
```

Ensuite, il faut redémarrer les services ceph des noeuds des clusters
avec :

```sh
# TODO: il faudra voir si cette étape n'est pas inutile.
#       La doc n'est pas très claire, à tester.
restart ceph-all
```

Puis, sur le radosgw :

```sh
service apache2 restart
start radosgw-all-starter
```

Ensuite un curl sur le serveur pour voir si ça marche. Par
exemple sur le serveur rados gateway, on doit avoir quelque
chose que ça (j'ai indenté la sortie pour que ce soit lisible) :

```
~# curl http://$(hostname)
<?xml version="1.0" encoding="UTF-8"?>
<ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
    <Owner>
        <ID>anonymous</ID>
        <DisplayName></DisplayName>
    </Owner>
    <Buckets></Buckets>
</ListAllMyBucketsResult>r
```

Sur le serveur radosgw, création d'un compte radosgw avec :

```sh
# TODO: voir s'il y a moyen d'imposer la access_key et la
#       secret_key.
radosgw-admin user create --uid=johndoe --display-name="John Doe" \
                          --email=john@example.com                \
                          --id radosgw.gateway
# Noter dans un coin la access_key et la secret_key.
```

Remarque : apparemment, ce compte est stocké quelque part dans
le cluster Ceph, pas dans le serveur radosgw. Encore une fois,
j'ai pu lire clairement dans certains documents qu'un radosgw
est un hôte stateless. Le compte créé n'est pas un compte
Ceph, c'est un compte au sens de radosgw (je ne sais pas
encore trop à quoi à ça correspond et j'ignore d'ailleurs
les droits de ce comptes). C'est bien indiqué dans la
documentation sur radosgw : « Since it provides interfaces
compatible with OpenStack Swift and Amazon S3, the Ceph
Object Gateway has its own user management. » En l'occurrence
lors de l'installation d'un radosgw, des pools sont créés
comme par exemples les pools `.users`, `.users.uid` etc.
et on peut supposer que c'est dans ces pools que les comptes
sont stockés.

Ensuite sur un hôte à part, un client qui va faire appel au
service de notre serveur radosgw, on va tenter d'utiliser
notre stockage ceph via notre radosgw. On suppose ici que
l'hôte client est une Ubuntu Trusty.

**Remarque :** pour faire du stockage type Amazon S3, les
sous domaines sont utilisés pour accéder à un bucket.
Par exemple, si le serveur radosgw s'appelle `radosgw.dom.tld`,
alors pour accéder aux objets du bucket `bucket-1`, les
clients S3 utiliseront le nom d'hôte `bucket-1.radosgw.dom.tld`.
Il faut donc que ce nom soit résolu en l'adresse IP du
radosgw. Dans la configuration d'un dnsmaq par exemple ça
se fait très simplement avec l'instruction :

```conf
# On suppose ici que l'IP de radosgw.dom.tld est bien
# 172.31.10.10.
address=/radosgw.dom.tld/172.31.10.10
```

Avec cette instruction, tout nom d'hôte de la forme
`*.radosgw.dom.tld` sera résolu en l'adresse 172.31.10.10.

Pour la configuration de ce client radosgw, je me suis aidé
de ce [lien](http://datacentred.co.uk/elastic-folders/).
On installe les paquets `s3cmd` et `s3ql`. Le premier
fournit la commande `s3cmd` qui est un client s3 (et donc un
client radosgw) en ligne de commandes. Le second fournit les
commandes `mkfs.s3ql` et `mount.s3ql` qui permettent de
formater et de monter un stockage Amazon S3 (et donc un
stockage radosgw) sur un répertoire local de sorte que l'on
peut écrire dans ce montage comme s'il s'agissait d'un
répertoire classique (avec une arborescence classique) alors
qu'en fait le stockage se fait sur radosgw (en stockage
objet) :

```sh
# Attention, si ce n'est pas le cas, il faut ajouter le dépôt
# "universe" dans les sources.list :
#
#   deb http://fr.archive.ubuntu.com/ubuntu/ trusty/universe amd64 Packages
#   deb http://fr.archive.ubuntu.com/ubuntu/ trusty-updates  universe
#   deb http://security.ubuntu.com/ubuntu/   trusty-security universe

apt-get update && apt-get install s3ql s3cmd
```

Ensuite, on crée le fichier de configuration `~/.s3ql/authinfo2`
qui servira à stocker les credentials utilisés par la commande
`mount.s3ql`. On édite ce fichier de la manière suivante :

```ini
[s3c]
storage-url:      s3c://
# Les clés sont accossiées au compte "johndoe" précédemment.
backend-login:    <ACCESS_KEY>
backend-password: <SECRET_KEY>
# Choisir un mot de passe de chiffrement de son choix.
# Ce sera le mot de passe utilisé lors du formatage s3ql
# du filesystem.
fs-passphrase:    <PASSWD>
```

Ensuite on configure le fichier `~/.s3cfg`, fichier de configuration
de la commande `s3cmd`, avec :

```sh
# C'est une commande interactive.
# Il faut indiquer les deux clés précédentes ainsi qu'un mot
# de passe de chiffrement que l'on choisit identique à la valeur
# du champ "fs-passphrase" du fichier ci-dessus. C'est
# ce mot de passe qu'il faudra indiquer lors du formatage s3ql.
# Pour le reste, on laisse les réponses par défaut (pas de https,
# pas de proxy etc). Enfin, la commande va tester la configuration
# générée mais ça ne va pas marcher car par défaut la configuration
# générée pointe vers le stockage vers le stockage de Amazon S3
# (à savoir s3.amazonaws.com). Donc, c'est normal et il faut garder
# la configuration malgré tout.
s3cmd --configure

# On configure les droits du fichier car sinon on a une erreur
# au niveau de la commande s3cmd.
chmod 600 ~/.s3cfg
```

On édite le fichier `~/.s3cfg` pour modifier les urls
correspondant au stockage. On modifie donc les deux lignes
suivantes :

```ini
host_base   = <FQDN-DU-RADOSGW>
host_bucket = %(bucket)s.<FQDN-DU-RADOSGW>
```

Ensuite, le stockage objet type s3 se partitionne en
buckets (seau). Il faut en créer un avec la commande
`s3cmd` qui est donc un client de stockage Amazon S3 :

```sh
# Ici, on crée le bucket "bucket-1".
s3cmd mb s3://bucket-1
```

Avec s3ql, on va pouvoir maintenant formater notre bucket
en un filesystem de type s3ql :

```sh
# Un mot de passe de chiffrement doit être choisi (à saisir
# deux fois). Il faut utiliser le mot de passe choisi lors
# de la configuration du fichier `~/.s3cfg` utilisé par la
# commande s3cmd.
fqdn="<FQDN-DU-RADOSGW>"
mkfs.s3ql --authfile ~/.s3ql/authinfo2 s3c://$fqdn/bucket-1
```
**Remarque :** il est possible d'ajouter l'option `--plain`
et dans ce cas le filesystem formaté n'a pas de mot de passe
de chiffrement (le champ "fs-passphrase" est alors inutile
au niveau du fichier `~/.s3ql/authinfo2`).



On est maintenant en mesure de monter notre filesystem s3ql :

```sh
fqdn="<FQDN-DU-RADOSGW>"
mount.s3ql --cachedir /tmp --authfile ~/.s3ql/authinfo2 \
    s3c://$fqdn/bucket-1 /mnt/
```

Pour démonter le filesystem, on lance :

```sh
umount.s3ql /mnt/
```


