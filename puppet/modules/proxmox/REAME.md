# Module description

This module provides a very light management of a Proxmox server.


# Usage

Here is an example:

```puppet
# Each user is an hash with a 'username' key and a 'email'
# key (optional).
$admin_users = [
  {
    'username' => 'root',             # Mandatory.
    'email'    => 'admin@domain.tld', # Optional.
  },
  {
    'username' => 'bob',
  },
  {
    'username' => 'alice',
    'email'    => 'alice@domain.tld',
  },
]
class { '::proxmox::params':
  admin_users => $admin_users,
  zfs_arc_max => '50%',
  swappiness  => 10,
}

include '::proxmox'
```


# Parameters

The `admin_users` parameter is a parameter to manage the
WebUI Proxmox users. The default value of this parameter is
an empty array `[]` and in this case the WebUI Proxmox users
are just not managed. If this parameter is not empty, the
Proxmox users are users with PAM authentication, so the
corresponding Unix accounts must exist (this module doesn't
manage any Unix account) and all users are "administrator" users.

**Remark:** this class provide a command
`pve-nosub-apt.puppet` to add/remove the no-subscription
Proxmox repository, to be able temporarily to make Proxmox
upgrade:
```sh
# Must be launched as root
pve-nosub-apt.puppet # Add the no-subscription APT repository if not present.
pve-nosub-apt.puppet # Remove the no-subscription APT repository if present.
```

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


