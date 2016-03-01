# Module description

This module implements the management of:

- cargo servers,
- lb server,
- captain server

in a moodle platform.


# Cargo server

## Usage

Here is an example:

```puppet
class { '::moo::params':
  shared_root_path => '/mnt/moodle',
}

include '::moo::cargo'
```

## Parameters



# Post-installation in captain

After the puppet run, you have to initialize the database
via the command (as root):

```sh
mysql -u root -h localhost --password='' < init-moobot-database.sql
```


# Usage

TODO: write the README, especially for `moo::cargo`
(complex data binding).


