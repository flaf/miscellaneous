# Module description

Module to set the keyboard configuration.

# Usage

Here is the declaration to have French keyboard:

```puppet
class { '::keyboard':
  xkbmodel   => 'pc105',
  xkblayout  => 'fr',
  xkbvariant => 'latin9',
  xkboptions => '',
  backspace  => 'guess',
}
```

See the code of the module to know the default values
of these parameters.


