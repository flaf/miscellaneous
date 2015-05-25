# Module description

This module contains some homemade and various functions.


# `is_supported_distrib()` function

Typical example of usage:

```puppet
class foo {

  is_supported_distrib(['truty', 'jessie'], $title)

  # The rest of the class.
  ...

}
```

The function raises an error if the distribution of the
current node is not present in the array of the first
argument, else the function does nothing.




