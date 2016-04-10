# TODO

* Update this README.


# Module description

This module allows to manage some Unix and non-system
accounts and their ssh public keys. Typically, this module
can be used to set the administrator accounts.




# The defined resource `unix_accounts::user`

Here is an example :

```puppet
$ssh_public_keys = {
  'foo@desktop-1' => {
     'type'     => 'ssh-rsa',
     'keyvalue' => 'XXXXXXXXX...',
  },
  'foo@desktop-2' => {
     'type'     => 'ssh-rsa',
     'keyvalue' => 'YYYYYYYYY...',
  },
}

unix_accounts::user { 'foo':
  #login               => 'foo',
  password             => '$6$ba08106dfd57328e$Z8fC...gfZmD',
  ensure               => present,
  #uid                 => 1001,
  #gid                 => 1001,
  #home                => '/home/foo',
  home_unix_rights     => '0750',
  managehome           => true,
  shell                => '/bin/bash',
  fqdn_in_prompt       => true,
  supplementary_groups => [ 'adm' ],
  membership           => 'inclusive',
  is_sudo              => true,
  ssh_authorized_keys  => [ 'foo@desktop-1', 'foo@desktop-1' ],
  purge_ssh_keys       => true,
  ssh_public_keys      => $ssh_public_keys,
}
```

This resource manages:

- the Unix account,
- the Unix rights of its home directory,
- the file `/etc/sudoers.d/${login}` if the account is sudo,
- some commodities in the files `${home}/.vimrc` and `${home}/.bashrc.puppet`,
- and the ssh authorized keys of the account.

**Warning:** there is one exception with the account root.
With the specific account root, the resource manages only :

- some commodities in the files `${home}/.vimrc` and `${home}/.bashrc.puppet`,
- and the ssh authorized keys of root.

Thus, with the root account, the only parameters taken into account
by the resource are :

- `ensure` but the only allowed value is `'present'`,
- `home` but the only allowed value is `'/root'`,
- `fqdn_in_prompt`,
- `ssh_authorized_keys`,
- `ssh_public_keys`.

So, for instance, the `password` parameter is completely
ignored when the resource is used for the root account. In
other words, you should not use this defined resource to
manage the root account. But the module (different of
defined resource above), can manage the password of the root
account (see below).




# The parameters of a defined resource `unix_accounts::user`

The `login` parameter is a string of the username. The
default of this parameter is the title of the resource.
This parameter is the equivalent of the `name` parameter
in the built-in `user` resource.

The `password` parameter is a string which contains de
user password in the "shadow" format. This parameter
has no default value, you must provide a value yourself.
This parameter is the equivalent of the `password` parameter
in the built-in `user` resource.

The `ensure` parameter is a string where only 3 values
are allowed :

- `'present'` in this case the user is created if needed etc.
- `'absent'` in this case the user will be removed if needed.
  The fact that its home will be removed of not depends on
  the value of the `managehome` parameter (see below).
- `'ignore'` in this case the user will be not managed at
  all, even its ssh authorized keys or its `.vimrc` etc.

The `uid` and `gid` parameters are the equivalent of the
`uid` and `gid` parameters in the built-in `user` resource.
The `uid` must be an integer and the `gid` can be a integer
of a name. The default value of these parameters is `undef`
and, in this case, when creating a new user, then one uid
and gid will be chosen automatically. The best is to let
these parameters undefined. But if you use these parameter,
it's not a good idea to change it or you can change it but
it's better to first remove the user (with `ensure ==
absent`) and recreate it after with the new values. If `gid`
is undefined, the primary group `foo` of a user `foo` will
be automatically created (or removed) by Puppet. But if the
`gid` parameter is defined, the primary group is not managed
at all (neither created, nor removed) and must exist before
the creation of the account.

The `home` parameter is the equivalent of the `home`
parameter in the built-in `user` resource. Its default value
is `/home/${login}` or `/root` if `$login == 'root'`.

The `home_unix_rights` is the Unix right of the home
directory. Its default value is `0700`.

The `managehome` parameter is a boolean to tell if Puppet
must manage, ie create or remove, the home directory during
the creation or the deleting of the user. This parameter
is the equivalent of the `managehome` parameter of the
built-in `user` resource. Its default value here is `true`.

The `shell` parameter is the equivalent of the `shell`
parameter of the built-in `user` resource. Its default
value is `/bin/bash`.

The `fqdn_in_prompt` is a boolean to tell is the prompt
should print the short name of the host or its fqdn.
Its default value is `false`. Warning, this parameter
is only effective for the shell bash.

The `supplementary_groups` is the equivalent of the
parameter `groups` in the built-in `user` resource.
Its an array of strings. If the account is sudo, the
sudo group will be automatically added in the array.
The primary group mustn't be put in this parameter.
The default value of this parameter is `[]`.

**Warnings:** each supplementary group *must exist*. If not,
it will raise an error.

The `membership` is the equivalent of the parameter
`membership` in the built-in `user` resource. The
only allowed values are `'inclusive'` and `'minimum'`.
If set to `'inclusive'`, the user account can't have
supplementary groups except the groups listed explicitly
in the `supplementary_groups` parameter. If set to
`'minimum'`, the groups listed in the `supplementary_groups`
parameter will be supplementary groups of the account,
but the account can belong to other groups. The default
value of the `membership` is `'inclusive'`.

The `is_sudo` parameter is a boolean. If set to `true`,
the account will be sudo and a file `/etc/sudoers.d/${login}`
will be managed. The default value of this parameter
is `false`.

The `ssh_authorized_keys` parameter is an array of strings
which contains the names of the ssh public keys added in
the file `.ssh/authorized_keys` of the account. The public keys
are present in the `ssh_public_keys` parameter. The default
value of the parameter `ssh_authorized_keys` is `[]`.

The `purge_ssh_keys` parameter is a boolean. If set to
`true`, then if a ssh public key is present in the file
`.ssh/authorized_keys` but not present in the paramater
`ssh_authorized_keys`, the key will be removed. The key will
be kept if set to `false`. The default value of this
parameter is `true`.

The `ssh_public_keys` parameter is a hash of public key.
This parameter must have the same structure as above.
However, the `type` key is optional and in this case the
default type is `ssh-rsa`.




# Usage of the module

Here is an example with this hiera configuration:

```yaml
unix_account::params::ssh_public_keys:
  bob@foo:
    type: 'ssh-rsa'
    keyvalue: 'XXXXXXXXX...'
  joe@bar:
    type: 'ssh-rsa'
    keyvalue: 'XXXXXXXXX...'
  bob@home:
    type: 'ssh-rsa'
    keyvalue: 'XXXXXXXXX...'

unix_account::params::users:
  root:
    password: '$6$ba08106dfd57328e$Z8fC...gfZmD'
    fqdn_in_prompt: true
    ssh_authorized_keys: [ 'bob@foo', 'joe@bar' ]
  bob:
    ensure: 'present'
    password: '$6$hg05606dfd57328e/Z8dc...afytD'
    is_sudo: true
    supplementary_groups: [ 'video', 'fuse' ]
    home_unix_rights: '0750'
    ssh_authorized_keys: [ 'bob@foo', 'bob@home' ]
```

and a simple include:

```puppet
include '::unix_account'
```

In a user, the entries are exactly the parameters of the
defined resource `unix_accounts::user` except `login` and
`ssh_public_keys`. The default values are exactly the same
except for `purge_ssh_keys` which `true` if `ensure ==
'present'` and `false` if not.




# Parameters of the class `unix_accounts::params`

For the two parameters of this class, `users` and
`ssh_public_keys`, the default value is `{}` (in
this case the module does absolutely nothing).

**Note concerning the merging policy:** for the parameters
`users` and `ssh_public_keys`, the merging policy is `deep`.

**Warning:** the root user resource is put in a specific
**internal** class `::unix_accounts::root`. For this class,
the `stage` parameter is set to `'basis'` by default (not
`'main'`).


