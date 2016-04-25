# The role `mcomiddleware`

This role sets a middleware server via RabbitMQ for a
MCollective environment.


## Usage

Here is an example:

```puppet
class { '::roles::mcomiddleware::params':
  exchanges => ['mysql', 'ceph'],
}

include '::roles::mcomiddleware'
```


## Parameter of `roles::mcomiddleware::params`

The `exchanges` parameter is an array of non-empty strings
to set exchanges. Its default value is `[ $::datacenter,
'mcollective' ] + $::datacenters` and its merge policy is
`unique`.


