# Module description

This module installs memcached and allows to set the
memory dedicated to this daemon.

# Usage

Here is an example:

```puppet
class { '::memcached::params':
  memory => 512,
}

include '::memcached'
```

The only parameter is `memory` which gives the memory
dedicated to the memcached daemon in MiB. Its default
value is 64 (ie 64 MiB). After that, memcached listens
to all interfaces on the port 11211.

# To have the status of memcached

```sh
echo stats | nc localhost 11211

# To have the RAM used by memcached.
echo stats | nc localhost 11211 | grep bytes

# To get the slab ids. In the output, the first number after
# "items" is the slab id (objects in the memcached memory
# are grouped in different slab classes <= not really sure).
echo stats items | nc localhost 11211

# To print the cache dump of the slab id == 3, with a
# limit for the max number of keys to dump (100 here).
stats cachedump 3 100 | nc localhost 11211
```


