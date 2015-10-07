# Module description

This module allows to manage some Unix and non-system
accounts and their ssh public keys. Typically, this module
can be used to set the administrator accounts.

# Usage

Here is an example:

```puppet
$users = { 'root' => { 'password'            => 'xxx',
                       'ssh_authorized_keys' => [ 'bob@foo',
                                                  'joe@bar',
                                                ],
                     },

           'bob'  => { 'ensure'              => 'present',
                       'password'            => 'yyy',
                       'is_sudo'             => true,
                       'ssh_authorized_keys' => [ 'bob@foo',
                                                  'boo@home',
                                                ],
                     }
         }

$ssh_public_keys = { 'bob@foo'  => 'XXXXXXXXX...',
                     'joe@bar'  => 'XXXXXXXXX...',
                     'boo@home' => 'XXXXXXXXX...',
                   }

class { '::unix_account':
  users           => $users,
  ssh_public_keys => $ssh_public_keys,
  fqdn_in_prompt  => true,
}
```

For the root account, only the parameters `password`
and `ssh_authorized_keys` are necessary. For this
account, the rest is just ignored.

For the other accounts, the parameters `ensure` and
`is_sudo` are optional. The `ensure` parameter can
take 2 values: the string `'present'` or the string
`'absent'` (to remove completely the account **and his
home**). The default value is `'present'`.

The `is_sudo` parameter is a boolean and its default
value is `false`.

The `fqdn_in_prompt` parameter is a boolean. If `true`,
the fqdn will be displayed in the prompt, if `false`
the short hostname will be used.




# Data binding

If the class is called without parameter, the module makes a
lookup of the `unix_accounts` entry in hiera or in
`environment.conf` to set the value of the `users` parameters
and makes a lookup of the `ssh_public_keys` entry to set the
value of the `ssh_public_keys` parameter. If the class is
called without any parameter, you must provide these two
entries. The default value of the `fqdn_in_prompt` parameter
is `false`.


