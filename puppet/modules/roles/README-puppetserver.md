# The role `puppetserver`

This role sets a puppetserver which can be too a MCollective
client. This role includes:

- the `roles::generic` class,
- the `puppetserver` class,
- the `mcollective::client` class.




## Usage

Here is examples:

```puppet
class { '::roles::puppetserver::params':
  is_mcollective_client => true,
  backup_keynames       => 'root@srv-1',
}

include '::roles::puppetserver'
```




## The parameters of `roles::puppetserver::params`


The `is_mcollective_client` is a boolean to tell if the node
must be too a mcollective client. The default value of this
parameter is `false`. If `true`, the class
`mcollective::client` will be included and the node will be
a mcollective client of the **same** middleware server used
by its mcollective service. To do that, the role uses
parameters from the class `mcollective::server::params` (see
the code).

The `backup_keynames` is an array of strings and its default
value is `[]`. This array **must** contain names of keys
which are listed in the parameter
`$::unix_accounts::params::ssh_public_keys`. These ssh
public keys will be put in th `authorized_backup_keys`
parameter of the class `puppetserver::params`.


