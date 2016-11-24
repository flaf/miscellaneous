# Module description

Module to set the timezone of the system.

# Usage

Here is an example:

```puppet
class { '::timezone::params':
  timezone => 'Europe/Paris',
}

include '::timezone'
```

The `timezone` parameter accepts only two values (two
strings): `Europe/Paris` or `Etc/UTC`. The default value of
this parameter is `Europe/Paris`.

# For information: set the timezone with shell

Normally it's:

```sh
timezone='Europe/Paris'

echo "$timezone" > /etc/timezone
dpkg-reconfigure --frontend="noninteractive" tzdata
```

But currently it doesn't work on Xenial. There is a bug report
[here](https://bugs.launchpad.net/ubuntu/+source/tzdata/+bug/1554806).
On Xenial, currently this works:

```sh
timezone='Europe/Paris'

ln -fs "/usr/share/zoneinfo/${timezone}" /etc/localtime
dpkg-reconfigure --frontend="noninteractive" tzdata
```

# TODO

* Update the module when the bug on Xenial will be fixed.


