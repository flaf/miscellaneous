# Module description

This module installs memcached and allows to set the
memory dedicated to this daemon.

# Usage

Here is an example:

```puppet
class { '::memcached':
  memory => 512,
}
```

The only parameter is `memory` which gives the memory
dedicated to the memcached daemon in MiB. Its default
value is 64 (ie 64 MiB). After that, memcached listens
to all interfaces.


