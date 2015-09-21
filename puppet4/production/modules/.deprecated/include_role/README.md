# Module description

Module to just include the "role" class of the current node.

# Usage

Example:

```puppet
class { '::include_role':
  role => '::role_foo',
}
```

This example is finally equivalent to:

```puppet
include '::role_foo'
```

But the interest of the `include_role` class is that the
value of its `role` parameter (generally a data from hiera)
is checked and must be non empty string.


