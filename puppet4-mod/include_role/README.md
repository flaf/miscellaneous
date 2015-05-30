# Module description

Module to just include the "role" class of the current node.

# Usage

Example:

```puppet
class { '::include_role':
  role => '::role_foo',
}
```

This example is equivalent to:

```puppet
include '::role_foo'
```

The only interest of the `include_role` is that the value of
the `role` parameter (which will generally be a data in hiera)
is checked and must be non empty string.


