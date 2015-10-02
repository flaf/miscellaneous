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



