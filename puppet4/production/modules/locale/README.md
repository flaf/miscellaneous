# Module description

This module just sets the default locale of the system.

# Usage

The `locale` class has only one parameter:

```puppet
class { '::locale':
  default_locale => 'fr_FR.utf8',
}
```

The `default_locale` parameter accepts only two values (two
strings): `fr_FR.utf8` or `en_US.UTF-8`. The default value
of this parameter is `en_US.UTF-8`.


