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

The default values of these parameters are exactly the
same as above so that this code is equivalent to a simple
`include`.


