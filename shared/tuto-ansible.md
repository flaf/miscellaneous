# Petit tutoriel sur Ansible

On va se donner 3 machines sous Debian Jessie,
toutes les 3 sur le même réseau IP :

* se3.athome.priv
* client1.athome.priv
* client2.athome.priv

On supposera que :

1. Quitte à mettre en place un serveur DNS ou alors en éditant
   le fichier `/etc/hosts` de se3, l'hôte se3 sera capable de
   résoudre correctement en adresse IP les fqdn ci-dessus.
2. Sur les trois hôtes, un serveur ssh est en place et
   python est installé.


## Installation et échanges des clés SSH

C'est sur se3 qu'on installe Ansible :

```sh
# Oui, c'est curieux il faut mettre "trusty" alors qu'on est sur Jessie.
# C'est marqué dans la doc Ansible :
#
#   http://docs.ansible.com/ansible/intro_installation.html#latest-releases-via-apt-debian
#
echo deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main > /etc/apt/sources.list.d/ansible.list

# Il nous faut la clé GPG du dépôt.
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367

apt-get update && apt-get install ansible
```

Il faut créer une paire de clés SSH sur se3 et échanger la clé
publique sur tous les « clients » ansible. En clair, sur se3,
il faut être en mesure de se connecter sur les « clients »
ansible de manière non-interactive.


```sh
# Génération d'une paire de clés SSH sans passphrase.
ssh-keygen

# On envoie la clé publique dans le fichier /root/.ssh/authorized_key
# de nos 3 « clients » ansible.
ssh-copy-id root@client1.athome.priv
ssh-copy-id root@client2.athome.priv
ssh-copy-id root@se3.athome.priv
```

Bien vérifier ensuite que, sur se3, on peut se « ssher » sur
les 3 fqdn sans mot de passe.



## Mise en place du fichier « d'inventaire » des clients ansible

Il faut éditer le fichier `/etc/ansible/hosts` et y placer
nos clients. Entre crochet, on définit des groupes de clients.

```ini
# Une adresse IP est possible à la place d'un fqdn.
[sambaedu]
se3.athome.priv

[linuxclients]
# De 1 à 2, on économise peu de lignes mais de 1 à 20 par exemple, c'est différent.
# À noter que la syntaxe [01:20] est possible aussi pour aller de 01, 02, etc. à 20.
client[1:2].athome.priv
```

On peut maintenant vérifier que ça fonctionne bien avec :

```sh
# "all" est un groupe pré-défini qui contient tous les clients.
ansible all -m ping

ansible linuxclients -m ping

ansible 'client1*' -m ping

# On peut afficher des informations sur un ou plusieurs clients :
ansible 'client1.athome.priv' -m setup
```


Et au passage, on est en mesure d'exécuter n'importe quelle commande shell
sur un ou plusieurs clients. Par exemple :

```sh
ansible all -a 'ls -al --color /tmp'
```




## Un petit playbook simple comme premier exemple

**Attention :** ceci est un exemple simple pour commencer
et comprendre les principes de base mais il ne correspond pas
aux bonnes pratiques au niveau de l'organisation des fichiers
(la bonne pratiques est d'utiliser des « rôles » ansible,
voir plus bas).

Un playbook est un fichier YAML utilisé par Ansible pour
mettre en place des configuration sur un ou plusieurs clients. Créons
ce fichier `~/myplaybook.yaml` :

```yaml
---
# Cette entrée ici (avec le tiret en début de ligne) marque
# le début d'un « play » dans le langage ansible, ie un
# machin qui va configurer des trucs sur un ensemble de
# clients.
#
# Un fichier playbook peut contenir autant de « plays » que
# l'on souhaite. Ici, on n'en met qu'un seul.
#
- hosts: linuxclients # <= Signifie que les clients du groupe linuxclients seront la cible de ce play.
  vars:               # <= Ici on définit des variables (voir plus bas).
    ntp_servers:
      - '0.debian.pool.ntp.org'
      - '1.debian.pool.ntp.org'
      - '2.debian.pool.ntp.org'
    admin_email: 'flaf@domain.tld' # Variable dont l'existence est artificielle ici, c'est pour l'exemple.
  remote_user: root
  tasks: # <======================== Les tasks sont toujours appliquées dans l'ordre où elles écrites.
    - name: ensure NTP installation
      apt:
        name: ntp
        state: latest
    - name: write NTP config file /etc/ntp.conf
      template:
        src: ntp.conf.j2 # <== Ici on utilise un template Jinja2 (la syntaxe est très simple).
        dest: /etc/ntp.conf
        owner: root
        group: root
        mode: '0644'
      notify:
        - restart ntp
    - name: ensure ntp is running (and enable it at boot)
      service:
        name: ntp
        state: started
        enabled: yes
  handlers:
    - name: restart ntp
      service:
        name: ntp
        state: restarted
```

`template`, `service`, `apt` etc. s'appellent des **modules
ansibles**. Ce sont des mini-programmes pour exécuter des
actions sur les clients Ansible. Chaque module admet des
options (par exemple `mode` est une option du module ansible
`template`) et tout cela est documenté. Ansible possède
toute une panoplie de modules dont on peut voir la liste
[ici](http://docs.ansible.com/ansible/list_of_all_modules.html)
(il existe par exemple un module `mount` pour assurer un montage,
un autre module `shell` pour exécuter une commande shell etc. etc).


Et voici notre fichier `~/ntp.conf.j2` qu'il faut créer au
même en endroit que notre playbook car on a mis le chemin
relatif `src: ntp.conf.j2` dans le playbook :

```cfg
# Ce fichier est managé par Ansible. Merci de ne pas
# l'éditer manuellement.
#
# Si vous avez un souci, merci d'envoyer un message à
# cette adresse : {{ admin_email }}.

driftfile  /var/lib/ntp/ntp.drift
statistics loopstats peerstats clockstats
filegen    loopstats  file loopstats  type day enable
filegen    peerstats  file peerstats  type day enable
filegen    clockstats file clockstats type day enable

{% for ntp_server in ntp_servers %}
server {{ ntp_server }} iburst
{% endfor %}

restrict -4 default kod notrap nomodify nopeer noquery
restrict -6 default kod notrap nomodify nopeer noquery

restrict 127.0.0.1
restrict ::1

{% if ansible_distribution_release == 'jessie' %}
# Configuration spécifique si on est sur une Jessie...
{% elif ansible_distribution_release == 'xenial' %}
# Configuration spécifique si on est sur une Xenial...
{% else %}
# Configuration par defaut...
{% endif %}
```

On va pouvoir lancer notre playbook avec la commande :

```sh
# L'option --diff permet de voir les lignes supprimées/ajoutées losqu'un
# fichier texte (un fichier de configuration) est modifié par ansible.
ansible-playbook ./myplaybook.yaml --diff
```

**Remarque :** on peut donc adapter un template en fonction du
client et de son OS par exemple (si c'est une Xenial ou une
Jessie etc.) avec des `{% if %}` (entre autres). Mais si le template
devient trop complexe et illisible, alors il plus sage de
créer des fichiers templates différents par exemple avec :

```cfg
# Il faut reconnaître que ntp n'est pas un bon exemple pour
# ça car la configuration est plutôt stable d'une distribution
# à l'autre.
~/ntp.conf_jessie.j2
~/ntp.conf_xenial.j2
```

Et dans le playbook mettre quelque chose comme ça :

```yaml
# [...]
    - name: write NTP config file /etc/ntp.conf
      template:
        src: 'ntp.conf_{{ansible_distribution_release}}.j2' # <= Changement ici.
        dest: /etc/ntp.conf
        owner: root
        group: root
        mode: '0644'
      notify:
        - restart ntp
# [...]
```



## La bonne pratique des rôle pour l'organisation des fichiers


L'idée des rôles c'est de rendre un playbook autonome et
générique, comme un peu petit « module » ou une sorte de
lib, afin qu'il puisse être utilisable ensuite dans d'autres
playbooks avec un système « d'include ».

Par défaut, le répertoire `/etc/ansible/` contient ceci :

```
/etc/ansible/
├── ansible.cfg
├── hosts
└── roles/
```

On va utiliser le répertoire `/etc/ansible/roles/` pour stocker
notre playbook de l'exemple précédent (qui configure ntp) sous
la forme d'un rôle qu'on appellera `ntp`. On va créer cette
arborescence :

```cfg
# On va retrouver, éclaté dans plusieurs fichiers dans
# /etc/ansible/roles/ntp/, le code qu'on avait dans notre
# playbook précédent.
/etc/ansible/
├── ansible.cfg
├── hosts
└── roles
    └── ntp # <======= Notre role "ntp". Le dossier roles/ est amené à contenir plusieurs rôles bien sûr.
        ├── defaults
        │   └── main.yaml   # <= Sert à définir les valeurs par défaut de nos variables (quand c'est pertinent).
        ├── handlers
        │   └── main.yaml   # <= Le (ou les) handler(s).
        ├── tasks
        │   └── main.yaml   # <= Les tasks de notre playbook d'exemple précédent.
        └── templates
            └── ntp.conf.j2 # <= Le template de notre playbook d'exemple précédent.
```

Créons l'arborescence :

```sh
mkdir -p /etc/ansible/roles/ntp/defaults/
touch    /etc/ansible/roles/ntp/defaults/main.yaml
mkdir -p /etc/ansible/roles/ntp/handlers/
touch    /etc/ansible/roles/ntp/handlers/main.yaml
mkdir -p /etc/ansible/roles/ntp/tasks/
touch    /etc/ansible/roles/ntp/tasks/main.yaml
mkdir -p /etc/ansible/roles/ntp/templates/
touch    /etc/ansible/roles/ntp/templates/ntp.conf.j2
```

Voici le contenu du fichier `/etc/ansible/roles/ntp/tasks/main.yaml` :

```yaml
---
# On met le contenu de la clé "tasks" de notre playbook précédent
# mais on ne met pas la clé "tasks" elle-même (juste le contenu).
- name: ensure NTP installation
  apt:
    name: ntp
    state: latest
- name: write NTP config file /etc/ntp.conf
  template:
    src: ntp.conf.j2 # <== Le nom du template est relatif au dossier "templates/" de notre rôle ntp.
    dest: /etc/ntp.conf
    owner: root
    group: root
    mode: '0644'
  notify:
    - restart ntp
- name: ensure ntp is running (and enable it at boot)
  service:
    name: ntp
    state: started
    enabled: yes
```

Le contenu de notre template `/etc/ansible/roles/ntp/templates/ntp.conf.j2`
va être légèrement modifié car une bonne pratique dans un
rôle est de **préfixer le nom des variables d'un rôle par le
nom du rôle**. On va donc procéder aux changements suivants :

```cfg
ntp_servers => ntp_servers     # Lui reste inchangé, coup de chance.
admin_email => ntp_admin_email
```

Voici donc le contenu du fichier `/etc/ansible/roles/ntp/templates/ntp.conf.j2` :

```cfg
# Ce fichier est managé par Ansible. Merci de ne pas
# l'éditer manuellement.
#
# Si vous avez un souci, merci d'envoyer un message à
# cette adresse : {{ ntp_admin_email }}.

driftfile  /var/lib/ntp/ntp.drift
statistics loopstats peerstats clockstats
filegen    loopstats  file loopstats  type day enable
filegen    peerstats  file peerstats  type day enable
filegen    clockstats file clockstats type day enable

{% for ntp_server in ntp_servers %}
server {{ ntp_server }} iburst
{% endfor %}

restrict -4 default kod notrap nomodify nopeer noquery
restrict -6 default kod notrap nomodify nopeer noquery

restrict 127.0.0.1
restrict ::1

{% if ansible_distribution_release == 'jessie' %}
# Configuration spécifique si on est sur une Jessie...
{% elif ansible_distribution_release == 'xenial' %}
# Configuration spécifique si on est sur une Xenial...
{% else %}
# Configuration par defaut...
{% endif %}
```

Pas de surprises pour le fichier `/etc/ansible/roles/ntp/handlers/main.yaml` :

```yaml
---
# Là aussi, on ne met pas la clé "handlers:" mais juste le contenu de cette clé.
- name: restart ntp
  service:
    name: ntp
    state: restarted
```

Il nous reste le fichier `/etc/ansible/roles/ntp/defaults/main.yaml`.
Il sert à définir des valeurs par défaut pertinentes pour
certaines variables... quand c'est possible (par exemple
pour une variable `password` il vaut mieux éviter d'en
définir une sachant que par défaut ansible provoque une
erreur si une variable se retrouve non définie).

Ici, notre rôle `ntp` ne contient que deux variables
`ntp_servers` et `ntp_admin_email`. A priori, seule la
première peut avoir une valeur par défaut raisonnable, d'où :

```yaml
---
# Ce fichier correspond au contenu de la clé "vars:" dans
# notre playbook précédent mais là encore sans la clé "vars:"
# elle-même.
ntp_servers:
  - '0.debian.pool.ntp.org'
  - '1.debian.pool.ntp.org'
  - '2.debian.pool.ntp.org'

# Pas de valeur par défaut pertinente pour cette variable a priori.
#
#ntp_admin_email: 'foo@bar.tld'
```

Et voilà, on a créé notre rôle ansible `ntp`. On peut le considérer
comme une sorte de « fonctions » générique qui admet
ici deux variables (`ntp_servers` et `ntp_admin_email`) et
qui permet de mettre en place une configuration du service
ntp.




## Mais comment on l'utilise notre rôle ntp maintenant ?

Et bien avec un playbook qui, comme on va le voir, va se retrouver
très réduit en taille, l'essentiel du code étant *encapsulé* dans
notre rôle (ici on a qu'un rôle mais dans la pratique un playbook
appliquera toute une série de rôles).

On va créer nos playbook à la racine du répertoire `/etc/ansible/`
à côté du répertoire `./roles/`. Par exemple on va créer un playbook
`sambaedu.yaml` qui s'appliquera au groupe `sambaedu` (qui
ne contient que se3) comme ceci :

```sh
touch /etc/ansible/sambaedu.yaml
```

ce qui donne ceci :

```
/etc/ansible/
├── ansible.cfg
├── hosts
├── sambaedu.yaml
└── roles
    └── ntp
```

Voici un exemple pour notre fichier `/etc/ansible/sambaedu.yaml` :

```yaml
---
- hosts: sambaedu # Ici c'est le groupe "sambaedu" (réduit à un seul hôte).
  vars:
    # On pourrait laisser non définie la variable ntp_servers et c'est sa
    # valeur par défaut dans le rôle "ntp" qui serait utilisée. Par contre,
    # on doit fournir une valeur à la variable ntp_admin_email car elle n'a
    # pas de valeur par défaut, elle.
    ntp_servers:
      - '0.debian.pool.ntp.org'
      - '1.debian.pool.ntp.org'
      - '2.debian.pool.ntp.org'
    ntp_admin_email: 'flaf@domain.tld'
  roles:
    - ntp
#   - roleA
#   - roleB
#   - ....    <= dans la vraie vie, on appliquera toute une série de rôles.
```

Créons également le playbook `/etc/ansible/linuxclients.yaml` comme ceci :

```yaml
---
- hosts: linuxclients
  vars:
    ntp_servers:
      - '192.168.0.10' # <= mettons l'IP de se3 dans le cas des clients Linux.
    ntp_admin_email: 'flaf@domain.tld'
  roles:
    - ntp
```

On pourra lancer nos playbooks comme ceci :

```sh
ansible-playbook /etc/ansible/sambaedu.yaml --diff
ansible-playbook /etc/ansible/linuxclients.yaml --diff

# Pour vérifier notamment que la synchronisation ntp des clients
# Linux se fait bien sur l'IP du se3
ansible linuxclients -a 'ntpq -pn4'
```



## Utilisation des variables d'hôtes et de groupes.

En fait, mettre les variables directement dans les playbooks n'est
pas non plus une bonne pratique. On voit par exemple que la valeur
de la variable `ntp_admin_email` est présente à deux endroits
différents (la duplication de données, c'est le mal).

On va utiliser les variables de groupes qui sont définies dans
des fichiers YAML (encore et toujours) dans des fichiers de
la forme :

```cfg
# Le nom du groupe est celui qui est indiqué dans le fichier
# /etc/ansible/hosts (entre crochets).
/etc/ansible/group_vars/<non-du-groupe>.yaml
```

On peut aussi définir des variables pour un hôte en particulier
avec des fichiers de la forme :

```cfg
# Le nom de l'hôte tel qu'indiqué dans le fichier /etc/ansible/hosts.
/etc/ansible/host_vars/<non-de-l-hôte>.yaml
```

Il faut d'abord créer les fichiers et répertoires qui n'existent
pas par défaut :

```sh
mkdir /etc/ansible/host_vars/
mkdir /etc/ansible/group_vars/
touch /etc/ansible/group_vars/all.yaml
touch /etc/ansible/group_vars/linuxclients.yaml
touch /etc/ansible/group_vars/sambaedu.yaml
touch /etc/ansible/host_vars/client1.athome.priv.yaml
```

On a alors :

```
/etc/ansible/
├── group_vars
│   ├── all.yaml
│   ├── linuxclients.yaml
│   └── sambaedu.yaml
├── host_vars
│   └── client1.athome.priv.yaml
├── roles
│   └── ntp/...
├── ansible.cfg
├── hosts
├── linuxclients.yaml
└── sambaedu.yaml
```

Dans le fichier `/etc/ansible/group_vars/all.yaml`, on va
définir des variables suivantes :

```yaml
---
# Cette variable par exemple, il faut s'attendre à en avoir besoin ici ou là.
# Ces deux variables ne concernent pas directement le rôle ntp.
sambaedu_ip: '192.168.0.10'
admin_email: 'flaf@domain.tld'

# A priori, la valeur de la variable ntp_admin_email doit être
# la même pour tous les clients et on prend la valeur de admin_email
# ci-dessus.
#
# Peut-être qu'un autre rôle aura aussi besoin de cette
# valeur là. En procédant ainsi, la valeur est définie une
# seule fois en haut du fichier.
ntp_admin_email: '{{ admin_email }}'
```

En revanche, la variable `ntp_servers` n'est pas encore définie.
On veut que cela soit les serveurs NTP du pool Debian pour se3 mais que
ce soit l'IP du se3 pour client1 et client2 (et pour tous les
clients Linux en somme). Du coup, on a :

```yaml
---
ntp_servers:
  - '0.debian.pool.ntp.org'
  - '1.debian.pool.ntp.org'
  - '2.debian.pool.ntp.org'
```

pour le fichier `/etc/ansible/group_vars/sambaedu.yaml` (sauf
pour la valeur  (en fait
on pourrait même ne rien mettre car la valeur par défaut du
rôle `ntp` nous conviendrait parfaitement) et enfin pour le
fichier `/etc/ansible/group_vars/linuxclients.yaml` :

```yaml
---
# Là aussi, ne pas écrire ici l'IP de se3 en dur une
# deuxième fois, il faut utiliser la variable sambaedu_ip
# définie plus haut.
ntp_servers:
  - '{{ sambaedu_ip }}'
```

On peut alors rééditer nos playbooks car nous n'avons plus
besoin du tout de la clé `vars`. On peut se contenter de :

```yaml
---
# Pour le fichier /etc/ansible/linuxclients.yaml.
- hosts: linuxclients
  roles:
    - ntp

# Pour le fichier /etc/ansible/sambaedu.yaml.
- hosts: sambaedu
  roles:
    - ntp

# La clé "vars" a été supprimée dans les deux fichiers.
```

Dans notre exemple simpliste, les deux playbooks contiennent
les mêmes rôles mais on peut imaginer que, dans le cas de
sambaedu, il y aura des rôles supplémentaires propres à se3 qu'on
ne retrouvera pas dans le playbook des clients Linux.

On peut à nouveau lancer nos playbook, normalement on devrait
avoir le résultat souhaité :

```sh
ansible-playbook /etc/ansible/sambaedu.yaml --diff
ansible-playbook /etc/ansible/linuxclients.yaml --diff
ansible linuxclients -a 'ntpq -pn4'
```

Mais imaginons que pour une raison particulière (peu importe
laquelle), il faut que client1 utilise lui aussi les
serveurs NTP du pool Debian pour sa synchronisation (juste
lui, on imagine c'est une exception parmi les clients Linux)
alors on peut utiliser le fichier `/etc/ansible/host_vars/client1.athome.priv.yaml`
et y mettre :

```yaml
ntp_servers:
  - '0.debian.pool.ntp.org'
```

Avec `ansible-playbook /etc/ansible/linuxclients.yaml --diff`, on
verra que seul client1 va changer son serveur ntp de référence.
L'idée ici est que pour l'hôte client1, la variable `ntp_servers`
est définie dans plusieurs fichiers mais c'est le fichier le
plus « précis » qui l'emporte. En fait, pour l'hôte client1,
Ansible lit dans cette ordre :

1. Les assignations de variables dans `./group_vars/all.yaml`,
2. Les assignations de variables dans `./group_vars/linuxclients.yaml`,
3. Les assignations de variables dans `./host_vars/client1.athome.priv.yaml`,

du plus général au plus précis et c'est la dernière assignation
qui l'emporte.



## Petite astuce pour appliquer un playbook en le limitant à un seul client

En fait, dans notre cas pratique, on imagine mal les clients Linux
tous allumés en même temps et par exemple dans le cas d'une intégration
d'un client, on voudra sans doute lancer le playbook sur un seul
client (celui qu'on veut intégrer). Pour limiter notre playbook
à un client en particulier, on va utiliser l'astuce suivante :
on va utiliser une variable `target` qui ne sera définie nulle part et
qu'on définira en ligne de commandes directement.

Dans le fichier `/etc/ansible/linuxclients.yaml`, changer la valeur
de la clé `hosts` et mettre :

```yaml
---
# Petite astuce supplémentaire ici. Au lieu de mettre "{{ target }}",
# la syntaxe ci-dessous permet de définir la valeur sur `linuxclients`
# par défaut si target n'est pas définie.
- hosts: "{{ target | default('linuxclients' }}"
  roles:
    - ntp
```

Désormais on peut faire :

```sh
# Le playbook lancé sur tous les clients du groupe linuxclients car target est non définie.
ansible-playbook /etc/ansible/linuxclients.yaml --diff

# Le playbook est lancé ici seulement sur le client client1.athome.priv.
ansible-playbook /etc/ansible/linuxclients.yaml --diff --extra-vars target='client1.athome.priv'
```



