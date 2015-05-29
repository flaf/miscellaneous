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
argument, else the function does nothing. The function
uses the `lsbdistcodename` facter to know the distribution
of the node and the comparisons are case sensitive.

The second argument is just to give to the function the
name of the class that invokes the function to provide
an explicit error message if the function fails.



