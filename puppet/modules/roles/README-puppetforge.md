# The role `puppetforge`

This role sets a puppetforge server to store private Puppet modules.
client. This role includes:

- the `roles::generic` class,
- and the `puppetforge` class.




## Usage

It's simple, this role has no parameter and uses only the
parameters of the included modules:

```puppet
include '::roles::puppetforge'
```



