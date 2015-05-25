# Module description

Module to just include the "role" class of the current node.

# Usage

Example:

```puppet
class { '::main':
  role => '::role_foo',
}
```

The module defines too the following stages:

* `basis` stage handled before the `network` stage;
* `network` stage handled before the `repository` stage;
* `repository` handled before the `main` stage (ie the default stage).



