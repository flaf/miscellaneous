# Module description

Module to set the timezone of the system.

# Usage

The `timezone` class has only one parameter:

```puppet
class { '::timezone':
  timezone => 'Europe/Paris',
}
```

The `timezone` parameter accepts only two values (two
strings): `Europe/Paris` or `Etc/UTC`. The default value
of this parameter is `Europe/Paris`.


