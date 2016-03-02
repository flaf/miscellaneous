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

The parameter `shared_root_path` is the directory used by
the cargo server to mount the ceph file system. Its default
value is `/mnt/moodle`.


# Post-installation in captain

After the puppet run, you have to initialize the database
via the command (as root):

```sh
mysql -u root -h localhost --password='' < init-moobot-database.sql
```


# Usage

TODO: write the README, especially for `moo::cargo`
(complex data binding).


