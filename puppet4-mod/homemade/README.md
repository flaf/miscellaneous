# Module description

This module contains some homemade and various functions.


# `is_supported_distrib()` function

Typical example of usage:

```puppet
class foo {

  ::homemade::is_supported_distrib(['truty', 'jessie'], $title)

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


# `ljust()` and `rjust()` functions

Examples of usage:

```puppet
$v = ::homemade::rjust('hello', 10, ' ') # will return '     hello'
$v = ::homemade::ljust('hello', 10, ' ') # will return 'hello     '
```

These functions are just wrappers of the `ljust()` and
`rjust()` ruby methods, except that:
* the first argument must be a non empty string,
* the second argument must be an integer `> 0`,
* the third argument must be a non empty string.



