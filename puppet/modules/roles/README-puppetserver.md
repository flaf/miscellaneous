# The role `puppetserver`

This role sets a puppetserver which can be too a MCollective
client. This role includes:

- the `roles::generic` class,
- the `puppetserver` class,
- the `mcollective::client` class.




## Usage

Here is examples:

```puppet
class { '::roles::puppetserver':
  is_mcollective_client => true,
  sshpubkey_tag         => "ppbackup@${::facts['networking']['fqdn']}",
}
```




## The parameters of `roles::puppetserver`


The `is_mcollective_client` is a boolean to tell if the node
must be too a mcollective client. The default value of this
parameter is `false` unless the hostname of the host is exactly
`puppet` where, in this case, the default value is `true`.
If `true`, the class `mcollective::client` will be included
and the node will be a mcollective client of the **same**
middleware server used by its mcollective service. To do
that, the role uses parameters from the class
`mcollective::server::params` (see the code).

The `sshpubkey_tag` is a non-empty string. This tag is
searched on all SSH public keys which are listed in the
parameter `$::unix_accounts::params::ssh_public_keys`. The
matching ssh public keys will be put in the
`authorized_backup_keys` parameter of the class
`puppetserver::params`. The default value of this parameter
is the value mentioned in the example above.


