# Module description

This module implements the management of:

- cargo servers,
- lb servers,
- captain servers

in a moodle platform.

The classes related to these types of server have several
common parameters because the same configuration file
`/opt/moobot/etc/moobot.conf` is managed on these servers.
Even if for instance, sometimes, a specific parameter can
be useless and not relevant in a cargo server but relevant
and crucial in a captain server etc.


# Cargo server

## Usage

Here is an example:

The first group of parameters below are common parameters
for each public class (`cargo`, `captain` and `lb`). This
group of parameters are used to fill the configuration file
`/opt/moobot/etc/moobot.conf`. No explanation is given for
these parameter, unless exception mentioned and the comments
put directly in this code. If not noticed, for these common
parameters, the default value is the value set below.

```puppet
class { '::moo::params':

  ### Common parameters ###

  # Used to define a mountpoint (see below)
  shared_root_path            => '/mnt/moodle',

  first_guid                  => 5000,
  default_version_tag         => 'latest',

  # The address of the haproxy load balancers (fqdns, IP
  # addresses etc). There is no default value, the user must
  # define this parameter explicitly.
  lb                          => [ 'lb1', 'lb2' ],

  # The fqdn, the address etc. of the MySQL server used by
  # the moodles. No default value.
  moodle_db_host              => '192.168.20.50',

  # The user used by the captain server to connect to the
  # MySQL server and create dedicated moodle databases.
  moodle_db_adm_user          => 'mooadm',

  # The password of the MySQL user above. No default value.
  moodle_db_adm_pwd           => '123456',

  # Prefix of the dedicated moodle databases created by the
  # captain server. No default value.
  moodle_db_pfx               => 'xyz',

  # The docker repository or the tag used to install moodle
  # docker image. No default value.
  docker_repository           => 'lovely_elea',

  # The number of moodle dockers that should be instancied.
  default_desired_num         => 2,

  # The fqdn, IP address etc. of the MySQL server which
  # hosts the `moobot` database. Normally, it should be the
  # captain server. No default value.
  moobot_db_host              => 'captain',

  # The MySQL password used by the moobot programms to
  # connect to the `moobot` database in captain. The MySQL
  # user used is not settable and it's necessarily `moobot`.
  moobot_db_pwd               => 'abcdef',

  # The addresses of the memcached servers used by the
  # moodles. No default value.
  memcached_servers           => [ 'tcp:://memcached01:11211', 'tcp:://memcached02:11211' ],

  # The path of the haproxy template file of the moobot
  # package and the path of the command to reload the
  # haproxy daemon.
  ha_template                 => '/opt/moobot/templates/haproxy.conf.j2',
  ha_reload_cmd               => '/opt/moobot/bin/haproxy_graceful_reload',

  # The haproxy login and password to visit this page
  # http://${IP_LB}:8080/haproxy?stats. No default value
  # for the ha_stats_pwd parameter.
  ha_stats_login              => 'admin',
  ha_stats_pwd                => 'ha-secret',

  # The fqdn, IP address etc. of the log server which will
  # receive the log from the haproxy load balancer.
  # The default value of this parameter is:
  #
  #  ::network::get_param($interfaces, $inventory_networks, 'log_server', undef)
  #
  # The flaf-network is a dependency of this present module.
  ha_log_server               => 'logserver-moo',

  # The format of the haproxy logs.
  ha_log_format               => '%{+Q}o\ %{-Q}b\ %{-Q}ci\ -\ -\ [%T]\ %r\ %ST\ %B\ %hrl',


  # The fqdn, IP address etc. and the port of the smtp
  # server used by the moodles to send emails.
  smtp_relay                  => $::network::params::smtp_relay,
  smtp_port                   => $::network::params::smtp_port,

  # The fqdns, IP addresses etc. of the mongodb servers used
  # by the moodles. No default value.
  mongodb_servers             => [ 'mongodb01:27017', 'mongodb02:27017' ],

  # The replicatset used by the mongodb servers.
  replicaset                  => $::mongodb::params::replset,


  ### Cargo spefic parameters ###
  docker_iface                => 'bond0.24',
  docker_bridge_cidr_address  => '172.19.0.1/24',
  docker_gateway              => '192.168.24.254',
  docker_dns                  => '192.168.23.11',
  iptables_allow_dns          => true,
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

The parameter `shared_root_path` is the directory used by
the cargo server to mount the ceph file system. Its default
value is `/mnt/moodle`. The value of this parameter is put
on the `moobot.conf` file.

The parameter `docker_iface` is the name of the host
interface used by the docker containers to contact the
outside. With iptables rules, there will be IP forwarding
between `$docker_iface` and the virtual interface `docker0`.
This parameter is a string and has no default value. So, the
user must define himself its value explicitly. The value of
this parameter must be an interface of the host defined in
the module `flaf-network` (which is a dependency of the
present module).

The parameter `docker_bridge_cidr_address` is the value of
the `--bip` option of the docker daemon (set in the file
`/etc/default/docker`). A value like `'172.17.0.0/16'` is
incorrect because the part before the slash is the IP
address of the `docker0` interface (you can use
`'172.17.0.1/16'` instead). In clear, the syntax of this
parameter is `<IP-of-docker0>/<mask>` which set the network
of the docker containers and the IP address of the `docker0`
interface. This IP address will be the gateway of the docker
container. The default value of this parameter is
`172.17.0.1/16`.

The parameter `docker_gateway` is the IP address of the
gateway used by docker. This is not the gateway of the
docker containers (which is given by the part before the
slash in the parameter `docker_bridge_cidr_address`). It's
the gateway used by the host to send packets from the docker
containers. For instance, when a docker container pings
Google, it uses its gateway (given by
`docker_bridge_cidr_address`) and the packet comes in the
`docker0` interface. Then the packet is forwarded to the
`docker_iface` interface (parameter described above) and,
then, the packet is sent via the gateway given by the
present `docker_gateway` parameter. In fact, the packets
from the docker containers use its own routing table (called
`dockertable`) which is defined in the file
`/etc/network/if-up.d/docker0-up`. The default value of the
parameter `docker_gateway` depends on the value of the
mandatory parameter `docker_iface`. Via functions from the
`flaf-network` module, the default value should be the
gateway of the network where `docker_iface` is defined.
Normally you shouldn't need to define this parameter
explicitly. If the module is unable to set a correct value
for this parameter (ie unable to find the gateway of the
`docker_iface` network), this parameter will be undefined
and the module will fail.

The `docker_dns` parameter is an array of IP addresses (ie
of strings) to define the DNS servers which will be used by
the docker containers. This parameter is the value of the
`--dns` docker options (defined in the file
`/etc/default/docker`). The default value of this parameter
is `[]` (an empty array). In this case, no `--dns` option is
just not defined and docker decides automatically the DNS
servers used by the docker containers.

The parameter `iptables_allow_dns` is a boolean. If `true`,
it defines iptables rules in the file
`/etc/network/if-up.d/docker0-up` to allow docker containers
to make DNS requests to a local DNS server on the current
host. It's interesting only if there is a local DNS server
installed on the host. The default value of this character
is `true` if, among the addresses in `docker_dns`, there is
one address which belongs to the current host (else the
value is `fasle` by default).

The parameter `ceph_account` is the name of the ceph account
used by the cargo server to mount the ceph file system. In
fact, this parameter is just the string which will be put in
the fstab line in the options `id=$ceph_account` and
`keyring=/etc/ceph/ceph.client.${ceph_account}.keyring`.
That's all. This class doesn't manage the keyring file
`/etc/ceph/ceph.client.${ceph_account}.keyring`. For that,
you can use the `flaf-ceph` module or do it manually. The
default value of this parameter is `cephfs`.

The parameter `ceph_client_mountpoint` is the directory of
the ceph file system which mounted by the cargo server. In
fact, this parameter is just the value of the option
`client_mountpoint=$ceph_client_mountpoint` in the fstab
line (indeed with cephfs, it's possible to mount only a
subdirectory of the ceph file system). The default value of
this parameter is `/moodle`.

The parameter `ceph_mount_on_the_fly` is a boolean. If set
to `true`, the cephfs will be automatically mounted during
the puppet run (and will not if set to `false`). Warning:
the cephfs mount uses ceph-fuse which seems to not well work
with puppet (sometimes the mount fails). So it's better to
keep the default value of this parameter, ie `false`, and
just reboot the server after the puppet run.

The `backup_dir` parameter is a directory where the moodle
backups will be put, if backups are enabled. This directory
is not managed and not created by Puppet. It must exist
after the OS installation (typically defined as mountpoint
during the OS installation). The default value of this
parameter is `/backups`. In this directory, if backups are
enabled (see below), then a filedir copy (from cephfs) and a
mysqldump of the database of each moodle will be put (via
a cron task).

The parameter `backups_retention` is an integer which gives
the number of backups per moodle to keep in `$backup_dir`.
The default value of this parameter is `2`.

The parameter `backups_moodles_per_day` is an interger which
gives the frequency of the backups per day. For instance, if
set to `2`, which the default value of this parameter, 2
moodles will be saved per day (each night) via the cron task
(if backups are enabled of course).

The parameter `make_backups` is a boolean. If set to `true`,
the backups via the cron task will be enabled, if set to
`false` the cron task is just removed and there will be no
backups of the moodles at all. The default of this parameter
is `false` (ie no backups enabled).


# Captain server

## Usage

Here is an example:

```puppet
class { '::moo::params':

  ### Common parameters (see explanation above) ###
  shared_root_path            => '/mnt/moodle',
  first_guid                  => 5000,
  default_version_tag         => 'latest',
  lb                          => [ 'lb1', 'lb2' ],
  moodle_db_host              => '192.168.20.50',
  moodle_db_adm_user          => 'mooadm',
  moodle_db_adm_pwd           => '123456',
  moodle_db_pfx               => 'xyz',
  docker_repository           => 'lovely_elea',
  default_desired_num         => 2,
  moobot_db_host              => 'captain',
  moobot_db_pwd               => 'abcdef',
  memcached_servers           => [ 'tcp:://memcached01:11211', 'tcp:://memcached02:11211' ],
  ha_template                 => '/opt/moobot/templates/haproxy.conf.j2',
  ha_reload_cmd               => '/opt/moobot/bin/haproxy_graceful_reload',
  ha_stats_login              => 'admin',
  ha_stats_pwd                => 'ha-secret',
  ha_log_server               => 'logserver-moo',
  ha_log_format               => '%{+Q}o\ %{-Q}b\ %{-Q}ci\ -\ -\ [%T]\ %r\ %ST\ %B\ %hrl',
  smtp_relay                  => $::network::params::smtp_relay,
  smtp_port                   => $::network::params::smtp_port,
  mongodb_servers             => [ 'mongodb01:27017', 'mongodb02:27017' ],
  replicaset                  => $::mongodb::params::replset,

  ### Captain specific parameters ###
  captain_mysql_rootpwd       => '987654',
}

include '::moo::captain'
```

## Parameters

The parameter `captain_mysql_rootpwd` is the MySQL root
password of the MySQL server hosted by the captain server.
This MySQL server will host the `moobot` database which
contains the repartition of the dockers in the cargo
servers. The parameter has no default value and must be set
by the user.


## Post-installation in captain

After the puppet run, you have to initialize the database
via the command (as root):

```sh
mysql -u root -h localhost --password='' < init-moobot-database.sql
```


# Lb server

## Usage

Here is an example:

```puppet
class { '::moo::params':

  ### Common parameters (see explanation above) ###
  shared_root_path            => '/mnt/moodle',
  first_guid                  => 5000,
  default_version_tag         => 'latest',
  lb                          => [ 'lb1', 'lb2' ],
  moodle_db_host              => '192.168.20.50',
  moodle_db_adm_user          => 'mooadm',
  moodle_db_adm_pwd           => '123456',
  moodle_db_pfx               => 'xyz',
  docker_repository           => 'lovely_elea',
  default_desired_num         => 2,
  moobot_db_host              => 'captain',
  moobot_db_pwd               => 'abcdef',
  memcached_servers           => [ 'tcp:://memcached01:11211', 'tcp:://memcached02:11211' ],
  ha_template                 => '/opt/moobot/templates/haproxy.conf.j2',
  ha_reload_cmd               => '/opt/moobot/bin/haproxy_graceful_reload',
  ha_stats_login              => 'admin',
  ha_stats_pwd                => 'ha-secret',
  ha_log_server               => 'logserver-moo',
  ha_log_format               => '%{+Q}o\ %{-Q}b\ %{-Q}ci\ -\ -\ [%T]\ %r\ %ST\ %B\ %hrl',
  smtp_relay                  => $::network::params::smtp_relay,
  smtp_port                   => $::network::params::smtp_port,
  mongodb_servers             => [ 'mongodb01:27017', 'mongodb02:27017' ],
  replicaset                  => $::mongodb::params::replset,

  ### No lb specific parameters ###
}

include '::moo::lb'
```

## Post-installation in lb

After the puppet run, you have to initialize the haproxy
configuration via the command (as root):

```sh
python /opt/moobot/bin/lb.py --force --verbose --debug
```


