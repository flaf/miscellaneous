# Module description

This module provides a very light management of a Proxmox server.


# Usage

Here is an example:

```puppet
class { '::proxmox::params':
  zfs_arc_max => '50%',
  swappiness  => 10,
}

include '::proxmox'
```


# Parameters

The parameter `zfs_arc_max` allows you to set the option
`zfs_arc_max` of the ZFS kernel module. You can provide an
integer (the size of ARC in bytes) or a string like `40%`
which represents the percent of the RAM. The default value
of this parameter is `undef`: in this case the option is not
managed and the default value of the ZFS module is used. Of
course, this parameter is relevant only if you use ZFS on
Linux in your Proxmox server.

The parameter `swappiness` allows you to set the Linux
kernel option `vm.swappiness`. You must provide a integer
from 1 to 100. The default value of this parameter is
`undef`: in this case the `vm.swappiness` Linux kernel
option is:

* not managed if `zfs_arc_max` is `undef`,
* set to 10 if `zfs_arc_max` is not `undef` (because it's
  a recommended value with ZFS).


