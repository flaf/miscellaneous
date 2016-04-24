# The role `mcomiddleware`

This role sets a middleware server via RabbitMQ for a
MCollective environment.


## Usage

Here is an example:

```puppet
class { '::roles::mcomiddleware::params':
  additional_exchanges => ['mysql', 'ceph'],
}

include '::roles::mcomiddleware'
```


## Parameter of `roles::mcomiddleware::params`

The `additional_exchanges` parameter is an array of
non-empty strings to set additional exchanges. Indeed, the
exchanges of the middleware server will be
`$additional_exchanges + $::datacenters`. The default value
of the parameter `additional_exchanges` is `[]` (and in this
case the exchanges are just `$::datacenters`).


