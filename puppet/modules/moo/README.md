# Module description

This module implements the management of:

- cargo servers,
- lb servers,
- captain servers,
- quick reverse proxy

in a moodle platform.

The classes related to these types of server have a common
parameter `mootbo_conf` to configure the same file
`/opt/moobot/etc/moobot.conf` which is managed on these
servers.




# The data type `Moo::MoobotConf`

Before to see examples, it's better to explain the structure
of the **common** (and important) parameter `moobot_conf`
which is present in the 4 public classes of this module:
`moo::cargo::params`, `moo::captain::params`,
`moo::lb::params` and the special class `moo::params` (see
below). The type of this parameter is the custom type
`Moo::MoobotConf` and here is an example below in yaml
format.

If a key as the comment `optional`, in this case the key is
optional and its default value is the value set in the
example below. If not, there is no default value and the
user must define this key explicitly.

For each class `moo::cargo::params`, `moo::captain::params`,
`moo::lb::params` and `moo::params`, **the default merging
policy of this parameter is `deep`**.

```yaml
moo::params::moobot_conf:

  main:
    # Optional. The directory where the filedirs of the
    # moodle dockers are put. Each docker will have a binded
    # volume in this directory for its filedir (in fact, the
    # volume directory is a subdirectory of the
    # shared_root_path directory).
    shared_root_path: '/mnt/moodle'

    # Optional. The minimal uid used to chown the filedirs
    # of each moodle dockers.
    first_guid: 5000

    # Optional. The tag of the docker image used by moobot
    # by default to run a moodle docker if the version_tag
    # field of this moodle is not set in the captain
    # database.
    default_version_tag: 'latest'

  jobs:
    # The fqdn of the haproxy load balancers used by the
    # cargo servers to put jobs in the captain database in
    # the `jobs` table.
    update_lb: [ 'lb1.domain.tld', 'lb2.domain.tld' ]

  docker:
    # The fqdn, the address etc. of the MySQL server used by
    # the moodles.
    db_host: '192.168.20.50'

    # Optional. The MySQL user used by the captain server to
    # connect to the MySQL server and create dedicated
    # moodle databases. This MySQL user must be created
    # before (with the correct password) in the moodle MySQL
    # server
    db_adm_user: 'mooadm'

    # The password of the MySQL user above.
    db_adm_password: 'xxxx...xxx'

    # Prefix of the dedicated moodle databases created by
    # the captain server.
    db_pfx: 'xyz'

    # The docker repository or the name of the docker image
    # used to run moodle dockers.
    repository: 'lovely_elea'

    # Optional. The number of moodle dockers that should be
    # instancied in all cargos cluster for instance if you
    # set this value to 2 and if you have 2 cargo servers, A
    # moodle "M" will have 2 docker instances, one per cargo
    # server.
    default_desired_num: 2

    # The fqdn, IP address etc. of the smtp server used by
    # the moodles to send emails.
    smtp_relay: 'smtp.domain.tld'

    # Optional. The port used to request the smtp server
    # above.
    smtp_port: 25

  database:

    # The fqdn, IP address etc. of the MySQL server which
    # hosts the `moobot` database. Normally, it should be the
    # captain server.
    host: 'captain.domain.tld'

    # Optional. The name of the captain database and the
    # MySQL username able to modify this database. In fact,
    # these keys are not changeable and the 'moobot' value
    # is the only possible value.
    name: 'moobot'
    user: 'moobot'

    # The MySQL password of the `moobot` MySQL user used by
    # moobot program to connect to the `moobot` database
    # in captain.
    password: 'xxx...xxx'

  memcached:
    # The addresses of the memcached servers used by the
    # moodles. Be careful to the specific syntax.
    servers:
      - 'tcp:://memcached01:11211'
      - 'tcp:://memcached02:11211'

  mongodb:
    # The fqdns, IP addresses etc. of the mongodb servers
    # used by the moodles with the port value.
    servers:
      - 'mongodb01.domain.tld:27017'
      - 'mongodb02.domain.tld:27017'
      - 'mongodb03.domain.tld:27017'

    # The replicatset used by the mongodb servers.
    replicaset: 'mongodbmoodle'

  haproxy:
    # Optional. The path of the haproxy template of the
    # moobot package and the path of the command to reload
    # the haproxy daemon. In fact, these keys are not
    # changeable and the values below are the only possible
    # values.
    template: '/opt/moobot/templates/haproxy.conf.j2'
    reload_cmd: '/opt/moobot/bin/haproxy_graceful_reload'

    # Optional. The haproxy login to visit this page
    # http://${IP_LB}:8080/haproxy?stats.
    stats_login: 'admin'

    # The haproxy password to visit this page
    # http://${IP_LB}:8080/haproxy?stats.
    stats_password: 'xxx...xxx'

    # The fqdn, IP address etc. of the log server which will
    # receive the logs from the haproxy load balancer.
    log_server: 'log-server.domain.tld'

    # Optional. The format of the haproxy logs.
    #
    # Warning, in fact the below value is not the real
    # default value because %{...} is the syntax to use
    # hiera interpolation. In fact, the real default value
    # of this parameter is the value below where each % is
    # replaced by %{literal('%')}. You can test it, it gives
    # a completely unreadable value. However, and it the
    # most important, the final default value retrieved by
    # Puppet is exactly the value below.
    log_format: '%{+Q}o\ %{-Q}b\ %{-Q}ci\ -\ -\ [%T]\ %r\ %ST\ %B\ %hrl'

  backup:
    # Optional. The path of the directory which will be used
    # to store the local backups of the moodles (backups
    # launched via a cron task).
    path: '/backups'

    # Optional. The regex to set the moodles which will be
    # not backuped. The regex uses the hostname of the
    # moodle.
    exceptions: '^(dev[0-9]+|test|backup)$'

    # Optional. The retention, in days, of local moodle
    # databases backups and filedirs tar.gz archives to
    # keep.
    db_retention: 10
    filedir_retention: 10
```

The class `moo::params` do nothing and its goal is just to
be able to put the value of the `moobot_conf` parameter in
one place in hiera, with the key `moo::params::moobot_conf`,
and then retrieve its value in the puppet code and use it
for the other classes (see examples below).




# Cargo server

## Usage

Here is an example:

```puppet
# Here, we retrieve the value of moobot_conf via the hiera key
# moo::params::moobot_conf.
include '::moo::params'
$moobot_conf = $::moo::params::moobot_conf

class { '::moo::cargo::params':
  moobot_conf                => $moobot_conf,
  docker_iface               => 'bond0.24',
  docker_bridge_cidr_address => '172.19.0.1/24',
  docker_gateway             => '192.168.24.254',
  docker_dns                 => '192.168.23.11',
  iptables_allow_dns         => true,
  ceph_account               => 'cephfs',
  ceph_client_mountpoint     => '/moodle',
  ceph_mount_on_the_fly      => false,
  backup_cmd                 => '/opt/moobot/maintenance/backup_moodle',
  make_backups               => false,
}

include '::moo::cargo'
```


## Parameters

The `moobot_conf` parameter is explained above.

The parameter `docker_iface` is the name of the host
interface used by the docker containers to contact the
outside. With iptables rules, there will be IP forwarding
between `$docker_iface` and the virtual interface `docker0`.
This parameter is a string and has no default value. So, the
user must define himself its value explicitly.

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
`172.19.0.1/16`.

The parameter `docker_gateway` is the IP address of the
gateway used by the host to redirect traffic from the
docker0 interface (ie from the containers).

In the example above, we have `docker_bridge_cidr_address`
equal to `172.19.0.1/24`, so the IP of the `docker0`
interface is `172.19.0.1` (ie the part before the `/`). Here
is a schema to understand some network parameters:

```
                            IP forwarding                    gateway docker_gateway ie 192.168.24.254
  docker  ====>  docker0    =============> docker_iface ===>  gateway specific for the traffic from
containers     (172.19.0.1)                  (bond0.24)                     docker0
```

This is not the gateway of the docker containers (which is
given by the part before the slash in the parameter
`docker_bridge_cidr_address`). It's the gateway used by the
host to redirect packets from the docker containers. For
instance, when a docker container pings Google, it uses its
gateway (given by `docker_bridge_cidr_address`) and the
packet comes in the `docker0` interface. Then the packet is
forwarded to the `docker_iface` interface (parameter
described above) and, then the packet is sent via the
gateway given by the present `docker_gateway` parameter. In
fact, the packets from the docker containers use its own
routing table (called `dockertable`) which is defined in the
file `/etc/network/if-up.d/docker0-up`. This parameter has
no default value and must be set explicitly.

The `docker_dns` parameter is an array of IP addresses (ie
of strings) to define the DNS servers which will be used by
the docker containers. This parameter is the value of the
`--dns` docker options (defined in the file
`/etc/default/docker`). The default value of this parameter
is `[]` (an empty array). In this case, the `--dns` option
is just not defined and docker decides automatically the DNS
servers used by the docker containers.

The parameter `iptables_allow_dns` is a boolean. If `true`,
it defines iptables rules in the file
`/etc/network/if-up.d/docker0-up` to allow docker containers
to make DNS requests to a **local** DNS server on the
current host (because by default a docker container can't
contact host processes). It's interesting only if there is a
local DNS server installed on the host. The default value of
this character is `false`.

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
the ceph file system which is mounted by the cargo server.
In fact, this parameter is just the value of the option
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

The `backup_cmd` parameter is the command used by the cron
task (if enabled) which makes moodle backups. The default
value of this parameter is `/opt/moobot/maintenance/backup_moodle`.

The parameter `make_backups` is a boolean. If set to `true`,
the backups via the cron task will be enabled, if set to
`false` the cron task is just removed and there will be no
backup of the moodles at all. The default of this parameter
is `false` (ie no backups enabled).




# Captain server

## Usage

Here is an example:

```puppet
include '::moo::params'
$moobot_conf = $::moo::params::moobot_conf

class { '::moo::captain::params':
  moobot_conf   => $moobot_conf,
  mysql_rootpwd => 'xxx...xxx',
  backup_cmd    => '/opt/moobot/maintenance/dump_captain_database 100',
}

include '::moo::captain'
```

## Parameters

The `moobot_conf` parameter is explained above.

The parameter `mysql_rootpwd` is the MySQL root password of
the MySQL server hosted by the captain server. This MySQL
server will host the `moobot` database which contains the
repartition of the dockers in the cargo servers. The
parameter has no default value and must be set by the user.

The parameter `backup_cmd` is the command used by a daily
cron task to backup the captain database, ie the `moobot`
database. The default value of this parameter is
`/opt/moobot/maintenance/dump_captain_database 100` where
100 is the retention. With 100, the captain server keeps old
SQL dumps of the database with a mtime less or equal to 100
days. SQL dumps are put in a subdirectory of the `/root/`
directory.


## Post-installation in captain

After the puppet run, you have to initialize the database
via the command (as root):

```sh
mysql -u root -h localhost --password='' < init-moobot-database.sql
```

**Warning:** maybe the `init-moobot-database.sql` doesn't
match exactly with the hostnames and/or the IP of your cargo
servers. In this case, you have to edit and change the end
of this file (the `INSERT` lines in the `cargos` tables).




# Load balancer server

## Usage

Here is an example:

```puppet
include '::moo::params'
$moobot_conf = $::moo::params::moobot_conf

class { '::moo::lb::params':
  moobot_conf         => $moobot_conf,
  redirect_http2https => false,
}

include '::moo::lb'
```

The `moobot_conf` parameter is explained above and it's the
only parameter of the class `moo::lb::params`.

The `redirect_http2https` parameter is a boolean. If set to
`true` a nginx server which listens to the port 8000 will
offer a simple http => https redirection. If set to `false`,
all the nginx configuration will be managed but the nginx
server will be stopped and disabled. The default value of
this parameter is `false`.


## Post-installation in lb

After the puppet run, you have to initialize the haproxy
configuration via the command (as root):

```sh
python /opt/moobot/bin/lb.py --force --verbose --debug
```




# The quick reverse proxy server

## Usage

Here is an example:

```puppet
class { '::moo::quickwproxy::params':
  listen             => [],
  public_domain      => 'elea.ac-versailles.fr',
  proxy_pass_address => "moolb-vip.${::domain}",
  ssl_cert           => "content of the cert.pem file...",
  ssl_key            => "content of the private.pem file...",
}

include '::moo::quickwproxy'
```

## Parameters

The `listen` parameter sets the `listen` Nginx instructions:
* With `[]` (the default), Nginx uses all interfaces on port
  443 and 80 (for http => https redirection).
* With `[ '192.168.23.10', '192.168.24.10' ]`, Nginx uses theses
  addresses to listen on ports 443 and 80 and that's all.

The `public_domain` is the domain used to contact moodles
and it must match with the SSL certificate. The default
value of this parameter is `$::domain`.

The `proxy_pass_address` parameter sets the `proxy_pass`
instruction of the Nginx. Its default value is "moolb-vip.${::domain}".

And `ssl_cert` and `ssl_key` are the contents of the SSL
certificate (a .pem file) and the SSL private key (a .pem
file).




