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

$sudo_commands = [
  {
    'host'    => 'srv-*',
    'run_as'  => 'ALL',
    'tag'     => 'NOPASSWD:',
    'command' => '/usr/bin/cmd_foo',
    'comment' => [
      'Blabla blabla blabla blabla.',
      'Blibli blibli blibli blibli.',
    ],
  },
  {
    'host'    => 'mysql-srv-*',
    'run_as'  => 'ALL',
    'tag'     => 'NOPASSWD:',
    'command' => '/usr/bin/cmd_bar',
    'comment' => [
      'Blabla blabla blabla blabla.',
      'Blibli blibli blibli blibli.',
    ],
  },
]

$extra_info = {
  'is_foo' => true,
  'foo'    => 'bar',
}

$settings = {
  'password'             => '$6$ba08106dfd57328e$Z8fC...gfZmD',
  'ensure'               => present,
  #'uid'                 => 1001,
  #'gid'                 => 1001,
  #'home'                => '/home/foo',
  'home_unix_rights'     => '0750',
  'managehome'           => true,
  'shell'                => '/bin/bash',
  'fqdn_in_prompt'       => true,
  'supplementary_groups' => [ 'adm' ],
  'membership'           => 'inclusive',
  'is_sudo'              => false,
  'sudo_commands'        => $sudo_commands,
  'ssh_authorized_keys'  => [ 'foo@desktop-1', 'foo@desktop-1' ],
  'purge_ssh_keys'       => true,
  'ssh_public_keys'      => $ssh_public_keys,
  'email'                => 'foo@domain.tld',
  'extra_info'           => $extra_info,
}

unix_accounts::user { 'foo':
  #login   => 'foo',
  settings => $settings,
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
manage the root account. But the *module* (different of the
defined resource above), can manage the password of the root
account (see below).




# The parameters of a defined resource `unix_accounts::user`

The `login` parameter is a string of the username. The
default of this parameter is the title of the resource.
This parameter is the equivalent of the `name` parameter
in the built-in `user` resource.

The `settings` parameter must match with the structure
of the type `Unix_accounts::UserSettings` and has no
default value. Here is some explanations about its keys.

The value of the `password` key is a string which contains
the user password in the "shadow" format. This key is
mandatory. This key is the equivalent of the `password`
attribute in the built-in `user` resource.

The value of the `ensure` key is a string where only 3
values are allowed :

- `'present'` in this case the user is created if needed etc.
- `'absent'` in this case the user will be removed if needed.
  The fact that its home will be removed of not depends on
  the value of the `managehome` parameter (see below).
- `'ignore'` in this case the user will be not managed at
  all, even its ssh authorized keys or its `.vimrc` etc.

The key `ensure` is mandatory.

The values of the `uid` and `gid` keys are the equivalent of
the `uid` and `gid` attributes in the built-in `user`
resource. The value of `uid` must be an integer and the
value of `gid` can be an integer or a name (ie a string).
These keys are optional and the default value of these keys
is `undef` and, in this case, when creating a new user, then
one uid and one gid will be chosen automatically. The best
is to not provide these keys. But, if you use these keys,
it's not a good idea to change it: you can change it but
it's better to first remove the user (with `ensure ==
absent`) and recreate it after with the new values. If `gid`
is undefined, the primary group `foo` of a user `foo` will
be automatically created (or removed) by Puppet. But if the
`gid` parameter is defined, the primary group is not managed
at all (neither created, nor removed) and must exist before
the creation of the account.

The `home` key is the equivalent of the `home` attribute in
the built-in `user` resource. This key is optional and its
default value is `/home/${login}` or `/root` if `$login ==
'root'`.

The value of the `home_unix_rights` key is the Unix right of
the home directory. This key is optional and its default
value is `0750`.

The value of the `managehome` key is a boolean to tell if
Puppet must manage, ie create or remove, the home directory
during the creation or the deleting of the user. This key is
the equivalent of the `managehome` attribute of the built-in
`user` resource. This key is optional and its default value
here is `true`.

The `shell` key is the equivalent of the `shell` attribute
of the built-in `user` resource. This key is optional and
its default value is `/bin/bash`.

The value of the `fqdn_in_prompt` key is a boolean to tell
is the prompt should print the short name of the host or its
fqdn. This key is optional and its default value is `false`.
Warning, this parameter is only effective for the shell
bash.

The `supplementary_groups` key is the equivalent of the
parameter `groups` in the built-in `user` resource. Its an
array of strings. If the account is sudo, the sudo group
will be automatically added in the array. The primary group
mustn't be put in this parameter. This key is optional and
its default value is `[]`.

**Warnings:** each supplementary group *must exist*. If not,
it will raise an error.

The `membership` is the equivalent of the parameter
`membership` in the built-in `user` resource. The
only allowed values are `'inclusive'` and `'minimum'`.
If set to `'inclusive'`, the user account can't have
supplementary groups except the groups listed explicitly in
the value of the key `supplementary_groups`. If set to
`'minimum'`, the groups listed in the value of the key
`supplementary_groups` will be supplementary groups of the
account, but the account can belong to other groups. This
key is optional and its default value key is `'inclusive'`.

The value of the `is_sudo` key is a boolean. If set to
`true`, the account will be sudo (ie the user will belong to
the `sudo` group) and a file `/etc/sudoers.d/${login}` will
be managed (to avoid password for - almost - all commands).
This key is optional and its default value is `false`.

The value of the key `sudo_commands` must match with an
array of `Unix_accounts::SudoCommand` and, if it is not
empty, it allows to manage the file
`/etc/sudoers.d/${login}`. This key is optional and its
default value is `[]`. Warning, if the value of `is_sudo` is
`true`, the value of `sudo_commands` must be empty.

The value of the key `ssh_authorized_keys` is an array of
strings which contains the names of the ssh public keys
added in the file `.ssh/authorized_keys` of the account. The
public keys are present in the `ssh_public_keys` parameter.
This key is optional and its default value is `[]`.

The value of the key `purge_ssh_keys` is a boolean. If set
to `true`, then if a ssh public key is present in the file
`.ssh/authorized_keys` but not present in the value of the
key `ssh_authorized_keys`, the key will be removed. The key
will be kept if it set to `false`. This key is optional and
its default value is `true` if the value of `ensure` is
`true`, else it's `false`.

The value of the key `ssh_public_keys` is a hash of public
keys. The value of this key must have the same structure as
above. However, the `type` key is optional and in this case
the default type is `ssh-rsa`. The key `ssh_public_keys` is
optional and its default value is `{}`.

The value of the key `email` is a string or `undef`. This
key is optional and its default value is `undef`. Currently,
this key is absolutely not used by the defined resource
`unix_accounts::user` and by all the module.

The value of the key `extra_info` is a hash. This key is
optional and its default value is `{}`. Currently, this key
is absolutely not used by the defined resource
`unix_account::user` and by all the module. But it can be
useful to put some data which can be used by another modules
in a role class, for instance.


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
    ensure: 'present'
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

unix_account::params::rootstage: 'basis'
```

and a simple include:

```puppet
include '::unix_account'
```

In a user key (root, bob) in the yaml file, the entries must
match with the type `Unix_accounts::UserSettings` (ie the
same structure as the `settings` parameter in the defined
resource `unix_account::user`).

In a user key in the yaml file, the default values for the
absent keys are exactly the same as the default value of the
keys in the `settings` parameter in the defined resource
`unix_account::user` **except** for the key
`ssh_public_keys` where the default value is the value of
the parameter `unix_account::params::ssh_public_keys`.




# Parameters of the class `unix_accounts::params`

For the two parameters `users` and
`ssh_public_keys`, the default value is `{}` (in
this case the module does absolutely nothing).

**Note concerning the merging policy:** for the parameters
`users` and `ssh_public_keys`, the default merging policy is
`deep`.

The `rootstage` parameter is a non-empty string to set
the stage of the root user management. Its default value
is `'main'`.




# Personal note

If a new parameter for the users must be added, the files
which should be modified will be found with this command:

```sh
rgrep 'USER_PARAMS' .
```


