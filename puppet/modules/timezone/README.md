# Module description

Module to set the timezone of the system.

# Usage

Here is an example:

```puppet
class { '::timezone::params':
  timezone => 'Europe/Paris',
}

include '::timezone'
```

The `timezone` parameter accepts only two values (two
strings): `Europe/Paris` or `Etc/UTC`. The default value of
this parameter is `Europe/Paris`.


