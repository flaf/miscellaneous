# Module description

This module implements a basic ssh configuration.

# Usage

Here is an example:

```puppet
# To just install the ssh client.
include '::basic_ssh::client'

# To configure the sshd daemon (very basic).
class { '::basic_ssh::server':
  permitrootlogin => 'yes'
}
```

The class `basic_ssh::client` has no parameter and just
installs the ssh client.

The class `basic_ssh::server` has only one parameter which
must be equal to the strings `yes`, `without-password`,
`forced-commands-only` or `no`. Its default value is
`without-password`.


