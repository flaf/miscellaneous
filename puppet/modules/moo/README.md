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
  docker_iface                => 'bond0.24',
  docker_bridge_cidr_address  => '172.19.0.1/24',
  docker_gateway              => '192.168.24.254',
  docker_dns                  => '192.168.23.11',
  iptables_allow_dns          => true,
  shared_root_path            => '/mnt/moodle',
  ceph_account                => 'cephfs',
  ceph_client_mountpoint      => '/moodle',
  ceph_mount_on_the_fly       => false,
  backups_dir                 => '/backups',
  backups_retention           => 2,
  backups_moodles_per_day     => 2,
  make_backups                => false,
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


