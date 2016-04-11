# Module description

This module just sets the default locale of the system.

# Usage

Here is an example:

```puppet
class { '::locale::params':
  default_locale => 'en_US.utf8',
}

include '::locale'
```

The `default_locale` parameter accepts only two values (two
strings): `fr_FR.utf8` or `en_US.UTF-8`. The default value
of this parameter is `en_US.UTF-8`.


