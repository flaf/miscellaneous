# Manipuler du json avec la commande jq

On a déjà vu qu'avec la commande jq on pouvait afficher du
json de manière claire :

```sh
# On suppose que cmd-json envoie du json sur stdout.
# En fait, « . » est un opérateur de la commande jq, un des
# plus importants même. C'est un filtre qui ne filtre...
# rien du tout. Il prend son entrée et la reproduit à
# l'identique en sortie.
cmd-json | jq '.'
```

Mais le plus intéressant c'est que la commande jq accepte en
argument toutes une série d'opérateurs qui peuvent être
chaînés les uns à la suite les autres. La page man de la
commande explique tous ces opérateurs mais voici quelques
exemples.

On imagine que la sortie de `cmd-json` est un json dont la
valeur associée à la clé `nodes` est un array. Voici comment
afficher uniquement cet array :

```sh
# On utilise l'opérateur .foo comme l'appelle la page man de jq.
cmd-json | jq '.nodes'

# En fait, l'opérateur .foo est un raccourci de l'écriture
# .["foo"] qui est certes plus longue à écrire mais sans
# doute plus compréhensible et plus pédagogique.
cmd-json | jq '.["nodes"]'

# Dans la suite, on utilisera cette écriture plus verbeuse
# mais plus claire.
```

Et si jamais on veut certains éléments de cet array, on
utilise l'opérateur `[]` :

```sh
# Pour avoir le premier élément de l'array uniquement.
cmd-json | jq '.["nodes"][0]'

# Pour avoir le dernier élément de l'array uniquement.
cmd-json | jq '.["nodes"][-1:]'

# Pour avoir les éléments de 0 à 4.
cmd-json | jq '.["nodes"][0:5]'
```

En fait, `[]` est un opérateur à part en entière et il peut
être utilisé seul. Les commandes ci-dessus sont par exemple
totalement équivalentes à celles ci-dessous qui utilisent
l'opérateur pipe `|` qui marche ni plus ni moins comme le
pipe sous un shell Unix :

```sh
# Le pipe est bien dans la chaîne qui fait office d'unique
# argument de la commande jq.
cmd-json | jq '.["nodes"] | .[0]'
cmd-json | jq '.["nodes"] | .[-1:]'
cmd-json | jq '.["nodes"] | .[0:5]'
```

L'opérateur pipe est très pratique, il permet de chaîner
différents opérateurs pour au final faire des traitements
complexes. Toujours dans notre exemple, supposons que la clé
`nodes` soit un array A constitués de hashes et que tous ces
hashes possèdent la clé `name`. Supposons que l'on souhaite
afficher dans la sortie de `cmd-json` uniquement les hashes
de l'array A dont la valeur associée à la clé `name` vaut
`osd-2`, exemple pratique tiré de la commande `ceph osd tree
--format json` dans Ceph. Voici comment faire :

```sh
# Comme on peut le voir, on obtient un sous array de A avec
# seulement les hashes dont "name" vaut "osd.2".
~# ceph osd tree --format json | jq '.["nodes"] | map(select(.["name"]  == "osd.2"))'
[
  {
    "primary_affinity": 1,
    "reweight": 1,
    "id": 2,
    "name": "osd.2",
    "type": "osd",
    "type_id": 0,
    "crush_weight": 4,
    "depth": 5,
    "exists": 1,
    "status": "up"
  }
]

# Il s'avère que le sous array qu'on obtient ne contient
# qu'un seul hash car "name" est une clé dont la valeur est
# unique pour chaque osd. Du coup, il peut être intéressant
# de n'avoir que le hash lui-même au lieu d'un array
# constitué d'un seul hash. Pour ce faire, on chaîne
# simplement `| .[0]` à la fin :
~# ceph osd tree --format json | jq '.["nodes"] | map(select(.["name"] == "osd.2")) | .[0]'
{
  "primary_affinity": 1,
  "reweight": 1,
  "id": 2,
  "name": "osd.2",
  "type": "osd",
  "type_id": 0,
  "crush_weight": 4,
  "depth": 5,
  "exists": 1,
  "status": "up"
}
```

Explications : avec le `.nodes` on obtient notre array A.
L'opérateur `map()` teste le filtre passé en argument, ie
`.["name"] == "osd.2"`, sur chacun des éléments de l'array
A. Autrement dit si un hash de l'array A vérifie bien
`.["name"] == "osd.2"` il est conservé dans la sortie, sinon
il en est supprimé. Du coup, à la fin, il nous reste dans
l'array que les hashes dont la valeur de la clé `name` vaut
`osd.2`.

On peut même ensuite modifier notre hash. On peut ajouter
une clé, supprimer une clé et modifier la valeur d'une clé :

```sh
# C'est juste pour raccourcir la longueur de la commande
# suivante et se focaliser uniquement sur la partie qui nous
# intéresse ici :
filter1='.["nodes"] | map(select(.["name"] == "osd.2")) | .[0]'

# Une affectation va modifier la valeur d'une clé si elle
# existe déjà, sinon la clé sera créée. L'opérateur `del()`
# permet de supprimer une clé.
#
# Au passage, l'opérateur `del()` ne se trouve même pas
# référencé dans la page man de jq sur Trusty alors que
# pourtant il existe bel et bien.
~# ceph osd tree --format json | \
    jq "$filter1"'| .["modified"] = true | del(.["id"]) | .["status"] = "down"'
{
  "modified": true,      # clé ajoutée
  "primary_affinity": 1,
  "reweight": 1,         # la clé "id" a été supprimée
  "name": "osd.2",
  "type": "osd",
  "type_id": 0,
  "crush_weight": 4,
  "depth": 5,
  "exists": 1,
  "status": "down"       # clé modifiée
}
```

Voir la page man de jq pour plus de détails. Il y a des `if`
possibles par exemple et bien d'autres opérateurs. L'étendue
des possibilités de jq semble vraiment très vaste.




