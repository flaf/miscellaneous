# Module description

This module installs and configures rsyncd.


# Usage

Here is an example:

```puppet
$modules = {
  # The key below is the module name.
  'backups' => {
    'path'       => '/backups',
    'read_only'  => false,
    'uid'        => 'root',
    'gid'        => 'root',
    'auth_users' => [ 'user1', 'user2' ],
  }
  'foo' => {
    'path'       => '/etc/foo',
    'read_only'  => true,
    'uid'        => 'foo',
    'gid'        => 'foo',
    'auth_users' => [ 'foo' ],
  }
}

# The values are the passwords of each user and the keys the
# usernames.
$users = {
  'user1' => 'xxx...xxx',
  'user2' => 'xxx...xxx',
  'foo'   => 'xxx...xxx',
}

class { '::rsyncd::params':
  modules => $modules,
  user    => $users,
}

include '::rsyncd'
```


# Parameters

The `modules` parameter are all the rsync-modules set in the
`/etc/rsyncd.conf` file. To know the exact structure of this
parameter, see the files `module.pp` [here](types/module.pp)
and `modules.pp` [here](types/modules.pp). The default value
of this parameter is `{}`.

The `users` parameter set the rsync users (in
`/etc/rsyncd.secret`) allowed to use a specific
rsync-module. All users set in each rsync-module must be
present in the `users` parameter. If not, there will be an
error. The default value of this parameter is `{}`.


