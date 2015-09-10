* A module to manage `/etc/hosts`.
* A module to manage `/etc/resolv.conf` and `unbound`.
* Bug with the `metadata.json` file (https://tickets.puppetlabs.com/browse/PUP-5209).
* A module to manage users. Something to just manage
admins accounts (`pwd`, `is_sudo`, bash configuration) and remove it if
they exist no longer.

Now:
 1. puppetagent
 2. puppetserver
 3. mcollective


* Interesting => https://github.com/dalen/puppet-puppetdbquery

* I have tried `strict_variables = true` to force error when
a variable is undefined but all is broken: `Error from DataBinding
'hiera' while looking up 'network::restart': uncaught throw
:undefined_variable`. Impossible to use this parameter.
On dirait que le serveur attend que la variable network::restart
soit défini dans hiera au niveau du fichier yaml de l'hôte,
sinon on a une erreur. Ce n'est pas ce que je comprends de la
doc de ce
[paramétrage](https://docs.puppetlabs.com/puppet/latest/reference/config_important_settings.html).

* le paramétrage `trusted_server_facts = true` permet
d'avoir accès côté clients au `$server_facts` dont voici
un exemple de contenu :

```
{"serverversion" => "4.2.1",
 "servername"    => "puppet4.athome.priv",
 "serverip"      => "172.31.14.5",
 "environment"   => "production"
}
```


