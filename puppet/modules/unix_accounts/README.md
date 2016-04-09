# TODO

* Update this README.

* Parameters used by root account :
    - `ensure` but must be 'present',
    - `home` but must be '/root',
    - `fqdn_in_prompt`
    - `ssh_authirized_keys`
    - `ssh_public_keys`


# Module description

This module allows to manage some Unix and non-system
accounts and their ssh public keys. Typically, this module
can be used to set the administrator accounts.

Remark: this module implements the "params" design pattern.




# Usage

Here is an example:

```puppet
$users = { 'root' => { 'password'            => 'xxx',
                       'ssh_authorized_keys' => [ 'bob@foo',
                                                  'joe@bar',
                                                ],
                     },

           'bob'  => { 'ensure'               => 'present',
                       'password'             => 'yyy',
                       'is_sudo'              => true,
                       'supplementary_groups' => [ 'video', 'fuse' ]
                       'home_unix_rights'     => '0755'
                       'ssh_authorized_keys'  => [ 'bob@foo',
                                                   'bob@home',
                                                 ],
                     }
         }

$ssh_public_keys = { 'bob@foo'  => { 'type'     => 'ssh-rsa',
                                     'keyvalue' => 'XXXXXXXXX...',
                                   },
                     'joe@bar'  => { 'type'     => 'ssh-rsa',
                                     'keyvalue' => 'XXXXXXXXX...',
                                   },
                     'bob@home' => { 'type'     => 'ssh-rsa',
                                     'keyvalue' => 'XXXXXXXXX...',
                                   },
                   }

class { '::unix_account::params':
  users           => $users,
  ssh_public_keys => $ssh_public_keys,
  fqdn_in_prompt  => true,
}

include '::unix_account'
```




# Parameters

**Note concerning the merging policy:** for the parameters
`users` and `ssh_public_keys`, the merging policy is `hash`.
For these parameters, its default value is `{}`.

For the root account, only the parameters `password` and
`ssh_authorized_keys` are handled. For this account, the
rest is just ignored.

For the other accounts, the parameters below are optional:
- `ensure`
- `is_sudo`
- `ssh_authorized_keys`
- `supplementary_groups`
- `home_unix_rights`

The `ensure` parameter can take 2 values: the string
`'present'` or the string `'absent'` (to remove completely
the account **and his home** etc.). The default value is
`'present'`.

The `is_sudo` parameter is a boolean and its default
value is `false`.

The `ssh_authorized_keys` parameter allows to add ssh public
key in the file `~/.ssh/authorized_keys` of the user. Its
default value is an empty hash (ie no ssh key added).

The `supplementary_groups` parameter is an array of the
supplementary groups of the user. This parameter doesn't
contain (and shouldn't contain) the primary group of the
user which is automatically set to the group `$user` (ie a
group with the same name as the user himself). If the
`is_sudo` parameter is set to `true`, the group `sudo` will
be automatically added in the `supplementary_groups`
parameter (it's useless to add it explicitly). The default
value of the `supplementary_groups` parameter is `[]` (ie an
empty array) which means that the user will have no
supplementary group (just the primary group `$user`) or
maybe just the `sudo` group if `is_sudo` is set to `true`.

**Warnings:** a) each supplementary group *must exist*. If
not, the module will raise an error. b) If a user is in the
group `foo` and if this group in not present if the array
`supplementary_groups`, the next puppet run *will remove*
the user from the group `foo`.

The `home_unix_rights` parameter is the Unix rights (in
octal format) of `/home/$user` directory. Its default value
is `0750`.

The `fqdn_in_prompt` parameter is a boolean. If `true`, the
fqdn will be displayed in the prompt of each users, if
`false` the short hostname will be used. Its default value
is `false`.

**Warning:** the root user resource is put in a specific
**internal** class `::unix_accounts::root`. For this class,
the `stage` parameter is set to `'basis'` by default (not
`'main'`).


