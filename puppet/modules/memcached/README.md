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

# To have the status of memcached

```sh
echo stats | nc localhost 11211

# To have the RAM used by memcached.
echo stats | nc localhost 11211 | grep bytes

echo stats items | nc localhost 11211

# The first number after "items" is the slab id. Request a
# cache dump for each slab id, with a limit for the max
# number of keys to dump:
stats cachedump 3 100 # 100 is the limit.
```


