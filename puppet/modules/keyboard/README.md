# Module description

Module to set the keyboard configuration.

# Usage

Here is the declaration to have a French keyboard:

```puppet
class { '::keyboard::params':
  xkbmodel   => 'pc105',
  xkblayout  => 'fr',
  xkbvariant => 'latin9',
  xkboptions => '',
  backspace  => 'guess',
}

include '::keyboard'
```

The default values of these parameters are exactly the
same as above.


