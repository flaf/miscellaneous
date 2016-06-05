# Module description

This module allows to manage:
- a Ceph cluster node,
- a Ceph client node,
- and a Ceph rados gateway.




# Warning 1: you must create the cluster yourself

This module manages installation and configuration of files
but no cluster will be up after a run puppet. After a puppet
run on each node of the cluster, you have to create and launch
the daemons yourself.


## Creation of partitions

If you have dedicated disks for monitors or OSDs, you must
create partitions via `gdisk` and you must format these
partitions on each node. With `gdisk`, you have to create a
part-label for each partition and you have to follow this
policy:

- `mon-<id>` for dedicated partitions of monitors,
- `osd-<id>` for dedicated partitions of OSDs,
- `osd-<id>-journal` for dedicated partitions of OSD journals.

With the scripts to create mon, OSD, mds etc. (see below),
you'll use the symlinks in `/dev/disk/by-partlabel/` which
will be added in the file `/etc/fstab`.

**Remark:** in fact, among the 3 naming rules above, only
the third concerning the OSD journals is absolutely required
because there is a udev rule to force the owner to `ceph` to
any device whose partlabel has this form `osd-*-journal`
(absolutely needed with OSD daemons).


It is highly recommended to use XFS as filesystem of the
OSDs and monitors working directory:

```sh
# Typically:
#
#  - /dev/sdb1 == /dev/disk/by-partlabel/osd-0-journal is used for the journal
#  - /dev/sdb2 == /dev/disk/by-partlabel/osd-0 is the working directory.
#
# Or, better, the journal is in a raw partition in another
# disk (ideally a SSD).
#
mkfs.xfs -f -L mon-ceph01 /dev/disk/by-partlabel/mon-ceph01
mkfs.xfs -f -L mon-ceph02 /dev/disk/by-partlabel/mon-ceph02
mkfs.xfs -f -L mon-ceph03 /dev/disk/by-partlabel/mon-ceph03

mkfs.xfs -f -L osd-0 /dev/disk/by-partlabel/osd-0
mkfs.xfs -f -L osd-1 /dev/disk/by-partlabel/osd-1
# Etc.
```

Keep in mind these points:

* It's generally the monitor with the minimal IP address
which is the leader.
* For the ID of monitors and mds, don't use a numeric IDs
but systematically **alphanumeric** IDs. In fact, the best
choice is to use the current short hostname as ID. For
instance `mon.ceph01`, `mds.ceph02` etc.


## Creations of the monitors (3 or 5 monitors)

You have to use the script `ceph-monitor-init` to create the
first monitor (it is the birth of cluster), and the script
`ceph-monitor-add` to create supplementary monitors. You can
use the `--help` option to have the available options. In any
cases, use the `noatime` mount option:

```sh
# For the first monitor.
ceph-monitor-init --device /dev/disk/by-partlabel/mon-ceph01   \
                  --mount-options noatime,defaults --id ceph01 \
                  --monitor-addr "$address_mon_1"

# If the working directory of the monitor is directly in the
# / partition, the command is:
ceph-monitor-init --id ceph01 --monitor-addr "$address_mon_1"
```

For the other monitors:

```sh
ceph-monitor-add --device /dev/disk/by-partlabel/mon-ceph02   \
                 --mount-options noatime,defaults --id ceph02 \
                 --monitor "$address_mon_1"

# If the working directory of the monitor is directly in the
# / partition, the command is:
ceph-monitor-add --id ceph02 --monitor "$address_mon_1"

# Etc...
```


## Creation of the OSDs

You have to use the script `ceph-osd-add` to create OSD
daemons. You can use the option `--help` to see the
available options:

```sh
ceph-osd-add --device /dev/disk/by-partlabel/osd-0          \
             --mount-options noatime,defaults               \
             --journal /dev/disk/by-partlabel/osd-0-journal \
             --weight 1.0 --osd-id 0

# ...

ceph-osd-add --device /dev/disk/by-partlabel/osd-7          \
             --mount-options noatime,defaults               \
             --journal /dev/disk/by-partlabel/osd-7-journal \
             --weight 1.0 --osd-id 7

# Etc...
```


## Creation of the ceph accounts

The keyring files are in `/etc/ceph/*.keyring`:

```sh
# The client.admin account is already created.
ceph auth add client.foo1 -i /etc/ceph/ceph.client.foo1.keyring
ceph auth add client.foo2 -i /etc/ceph/ceph.client.foo2.keyring
# Etc...
```


## Creation of Cephfs (if needed)

First, creation of the mds daemon with `ceph-mds-add`. For
the ID, you should use the short hostname of the current
host:

```sh
ceph-mds-add --id ceph01 # on ceph01
ceph-mds-add --id ceph02 # on ceph02
# Etc...
```

Second, the creation of the cephfs filesystem:

```sh
# Be careful to the create the right pool which match with
# the rights of the ceph account.
ceph osd pool create cephfsdata     $pg_num_data
ceph osd pool create cephfsmetadata $pg_num_metadata
ceph fs new cephfs cephfsmetadata cephfsdata

# To check that all is OK.
ceph fs ls
ceph -s # the line fsmap should be present.
```


# Warning 2 : journals have to be a GPT partition with a specific partlabel

If the journal is not a standard file in the OSD working
directory but a symlink to a raw partition, the partition
has to be a GPT partition with this pattern for the
part-label: `osd-*-journal`. Indeed, since Infernalis, the
OSD daemons use the dedicated `ceph` Unix account and the
journal must have this account as owner (without that the
OSD daemon just can't start). This puppet module put a udev
rule so that `ceph` is automatically the owner of each GPT
partition whose part-label matches this pattern
`osd-*-journal` (where typically `*` matches a number).

In fact, we recommended this:
- for a OSD working directory, use a dedicated GPT partition
with `osd-$id` as part-label and `osd-$id` as fs-label.
- for a OSD journal, use a raw (without file system) dedicated
GPT partition with `osd-$id-journal` as part-label.


# Warning 3 : you must configure the `/etc/hosts` correctly

For each node of the cluster and for each client of the
cluster, it's recommended to configure the `/etc/hosts`
file to have:

```conf
<IP-monitor-1>      <fqdn-mon-1>      <short-name-mon-1>
<IP-monitor-2>      <fqdn-mon-2>      <short-name-mon-2>
<IP-monitor-3>      <fqdn-mon-3>      <short-name-mon-3>
# etc...
```

This module doesn't manage the `/etc/hosts` file and you
should configure this file with another puppet class, with
a role class for instance (or manually).


# The `ceph::node` defined resource

Be careful, this is not a class but a `define` resource.

## Usage

To be readable, here is the value of the important
`cluster_conf` parameter in yaml format:

```yaml
# The fsid can be generated with:
#
#     apt-get install uuid-runtime && uuidgen
#
# The key of a ceph account can be generated with:
#
#     apt-get install ceph-common && ceph-authtool --gen-print-key
#
cluster_conf:
  global_options:
    fsid: 'a33ef215-d9b4-4c6f-a500-ef14665e7d93'
    cluster_network:  '10.0.0.0/24'
    public_network: '172.16.0.0/16'
    auth_cluster_required: 'cephx'
    auth_service_required: 'cephx'
    auth_client_required: 'cephx'
    filestore_xattr_use_omap: 'true'
    osd_pool_default_size: '3'
    osd_pool_default_min_size: '1'
    osd_pool_default_pg_num: '64'
    osd_pool_default_pgp_num: '64'
    osd_crush_chooseleaf_type: '1'
    osd_crush_update_on_start: 'false'
    osd_journal_size: '0'
    osd_max_backfills: '1'
    osd_recovery_max_active: '1'
    osd_client_op_priority: '63'
    osd_recovery_op_priority: '1'
    osd_op_threads: '4'
    mds_cache_size: '1000000'
    osd_scrub_begin_hour: '3'
    osd_scrub_end_hour: '5'
    mon_allow_pool_delete: 'false'
    mon_osd_down_out_subtree_limit: 'host'
    mon_osd_min_down_reporters: '4', # set to (#OSDs per node) + 1 is a good idea
  monitors:
    ceph01:
      id: 'ceph01'
      address: '172.16.10.1'
    ceph02:
      id: 'ceph02'
      address: '172.16.10.2'
    ceph03:
      id: 'ceph03'
      address: '172.16.10.3'
  keyrings:
    admin:
      key: 'AQBZnFNXCccUOBACKOOwJ66qq9kOcbAMB6ciuw=='
      capabilities:
        mon: [ 'allow *' ]
        osd: [ 'allow *' ]
        mds: [ 'allow' ]
    cephfs:
      key: 'AQCAnFNXZf98KhDAqBAaHNDdeVz7GuOX9rW1Mg=='
      capabilities:
        mon: [ 'allow r' ]
        osd:
          - 'allow class-read object_prefix rbd_children'
          - 'allow rwx pool=cephfsdata'
        mds: [ 'allow' ]
    radosgw.gateway:
      key: 'AQCdnFNXOLyaMhABFrZKfXQy9dU8zOVR1uozoQ=='
      capabilities:
        mon: [ 'allow r' ]
        osd:
          - 'allow rwx pool=.rgw.root'
          - 'allow rwx pool=default.rgw.control'
          - 'allow rwx pool=default.rgw.data.root'
          - 'allow rwx pool=default.rgw.gc'
          - 'allow rwx pool=default.rgw.log'
          - 'allow rwx pool=default.rgw.users.uid'
          - 'allow rwx pool=default.rgw.users.email'
          - 'allow rwx pool=default.rgw.users.keys'
          - 'allow rwx pool=default.rgw.meta'
          - 'allow rwx pool=default.rgw.buckets.index'
    radosgw.gateway2: # An radodgw account which can create needed pools himself.
      key: 'AQACnlNXjMTSGRAAt6tEwVYW15Kqxf/UShFgYw=='
      capabilities:
        mon: [ 'allow rwx' ]
        osd: [ 'allow rwx' ]
  rgw_instances:
    radosgw.gateway:
      hosts: [ 'ceph-rgw' ]
      keyring: 'radosgw.gateway'
      rgw_dns_name: 'store.%{::domain}'
    radosgw.gateway2:
      hosts: [ 'ceph-rgw2' ]
      keyring: 'radosgw.gateway2'
      rgw_dns_name: 'store.%{::domain}'
```

Here is an example where `$cluster_conf` has the value
from the yaml file above:

```puppet
# The case of a "cluster" node.
ceph::node { 'ceph':
  cluster_name => 'ceph',
  cluster_conf => $cluster_conf,
  nodetype     => 'clusternode',
}

# The case of a "radosgw" node.
ceph::node { 'ceph':
  cluster_name => 'ceph',
  cluster_conf => $cluster_conf,
  nodetype     => 'radosgw',
}

# The case of a "client" node.
ceph::node { 'ceph':
  cluster_name => 'ceph',
  cluster_conf => $cluster_conf,
  nodetype     => 'clientnode',
  client_accounts => [ 'cephfs' ],
}
```




# Usage

Here is an example:

```puppet
$ceph_global_conf = {
  'fsid'                           => 'f875b4c1-535a-4f17-9883-2793079d410a',
  'cluster_network'                => '192.168.22.0/24',
  'public_network'                 => '10.0.2.0/24',
  'auth_cluster_required'          => 'cephx',
  'auth_service_required'          => 'cephx',
  'auth_client_required'           => 'cephx',
  'filestore_xattr_use_omap'       => 'true',
  'osd_pool_default_size'          => '2',
  'osd_pool_default_min_size'      => '1',
  'osd_pool_default_pg_num'        => '64',
  'osd_pool_default_pgp_num'       => '64',
  'osd_crush_chooseleaf_type'      => '1',
  'osd_crush_update_on_start'      => 'false',
  'osd_journal_size'               => '0',
  'osd_max_backfills'              => '1',
  'osd_recovery_max_active'        => '1',
  'osd_client_op_priority'         => '63',
  'osd_recovery_op_priority'       => '1',
  'osd_op_threads'                 => '4',
  'mds_cache_size'                 => '1000000',
  'osd_scrub_begin_hour'           => '3',
  'osd_scrub_end_hour'             => '5',
  'mon_allow_pool_delete'          => 'false',
  'mon_osd_down_out_subtree_limit' => 'host',
  'mon_osd_min_down_reporters'     => '4', # set to (#OSDs per node) + 1 is a good idea
}

# To generate a key, you can use with this command:
#
#     apt-get install ceph-common && ceph-authtool --gen-print-key
#
$ceph_keyrings = {
  'admin' => {
    'key'        => 'AQBzfhRW3FU7BRAA75c8O7ZcJRwNMHrhLtSA3Q==',
    'properties' =>  [
      'caps mon = "allow *"',
      'caps osd = "allow *"',
      'caps mds = "allow"',
    ],
  },
  'cephfs' => {
    'key'        => 'AQB1fhRWkM5tFxAADYKzOgTbDZw9LEMgbPw4yw==',
    'properties' =>  [
      'caps mon = "allow r"',
      'caps osd = "allow class-read object_prefix rbd_children, allow rwx pool=cephfsdata"',
      'caps mds = "allow"',
    ],
  },
  'radosgw.gw1' => {
    'key'           => 'AQDofhRWBh/ZBBAAtaRA4J9VHl7srhYyxo5pig==',
    'radosgw_host'  => 'radosgw-1',
    'rgw_dns_name'  => 'rgw.domain.tld',
    'properties'    =>  [
      'caps mon = "allow rwx"',
      'caps osd = "allow rwx"',
    ],
  },
  'radosgw.gw2' => {
    'key'           => 'AQDyfhRWdN50ARAATcfy7itnU1KyUKoX+XNi8g==',
    'radosgw_host'  => 'radosgw-2',
    'rgw_dns_name'  => 'rgw.domain.tld',
    'properties'    =>  [
      'caps mon = "allow rwx"',
      'caps osd = "allow rwx"',
    ],
  },
  'cinder' => {
    'key'           => 'AQDzfhRWjOwnIRAA9OV8cFbwnLyQElQl2jPy6g==',
    'owner'         => 'cinder',
    'group'         => 'cinder',
    'mode'          => '0640',
    'properties'    =>  [
      'caps mon = "allow r"',
      'caps osd = "allow class-read object_prefix rbd_children, allow rwx pool=volumes"',
    ],
  },
}

$clusters_conf = {
  'ceph'      => {
    'global_options' => $ceph_global_conf,
    'keyrings'       => $ceph_keyrings,
    # Below, 'mon-1', 'mon-2' and 'mon-3' must be the real short hostname
    # of the monitor servers.
    'monitors'       => { 'mon-1' => {'id' => 'ceph01', 'address' => '10.0.2.150'},
                          'mon-2' => {'id' => 'ceph02', 'address' => '10.0.2.151'},
                          'mon-3' => {'id' => 'ceph03', 'address' => '10.0.2.152'},
                        },
  },
  'cluster-a' => {
    # Another cluster...
  },
}

$client_accounts = {
  'ceph'      => [ 'cinder', 'cephfs', ],
  'cluster-a' => [ ... ],
}

class { '::ceph':
  clusters_conf   => $clusters_conf,
  client_accounts => $client_accounts,
  is_clusternode  => true,
  is_clientnode   => true,
}
```

The `clusters_conf` parameter is a hash where each key
is the name of a cluster and its value is the configuration
of this cluster (generally the hash has just one key
for just one cluster whose name is `ceph`). Like in the
example above, the configuration of a cluster **must** have:

* the `global_options` key,
* the `keyrings` key,
* and the `monitors` key.

In a keyring, the mandatory keys are:

* `key` (you can use `ceph-authtool --gen-print-key` to generate a value),
* and `properties`.

`owner`, `group`  and `mode` are optional with the default
values `root`, `root` and `0600`.

Keyrings whose name begins with `radosgw` are special
because the `radosgw_host` key is mandatory too in this case
and the value must be the short hostname of the radosgw
server which will use this keyring. With a radosgw keyring,
the key `rgw_dns_name` is optional (necessary when you use a
S3 bucket with this syntax
`<bucket-name>.<value-of-rgw_dns_name>` which should be
avoided because the syntax `<fqdn>/<bucket-name>` is better).

The `client_accounts` parameter is useful for a client
node (it can be empty `{}` for a cluster node). This
parameter contains the keyrings of Ceph accounts which
will be installed in the client node in `/etc/ceph/`.
This parameter is a hash with this form:

```puppet
$client_accounts = {
  '<cluster-X>' => [ '<a-account1-from-cluster-X>', '<a-account2-from-cluster-X>' ],
  '<cluster-X>' => [ '<a-account1-from-cluster-Y>', '<a-account2-from-cluster-Y>' ],
  # etc...
}
```

In this context too, a radosgw account (ie a account whose
name matches the regex `/^radosgw/`) is special because it
triggers on the client node the installation of the S3 http
service (ie the `radosgw` service).

The `is_clusternode` and `is_clientnode` parameters are
boolean which tell if the node is a cluster node or a
client node or both. Depending on the case (cluster node
or client node), the packages installed are a little
different. Of course, in a client node there will be no
osd or mon daemon but another important difference is:

* in a cluster node, all keyrings of the cluster are installed
in the `/etc/ceph/` directory;
* in a client node, only keyrings in the `client_accounts`
parameter are installed in the `/etc/ceph/` directory. For
instance, in a simple client node, normally you should never
have the keyring of the `admin` account.




# Data binding

There is no default hiera lookup in this module. Just
the classical mechanisms of data binding are used. Here
is the default values of the parameters:

* `clusters_conf => undef` so you must provide the clusters
configuration yourself,
* `client_accounts => {}` ie no client account by default,
* `is_clusternode => false`,
* `is_clientnode => false`.

Here is a hiera configuration equivalent to the call in the
`Usage` section above.

First, in a yaml file shared by all the nodes (ie the cluster
nodes **and** the client nodes), you can put:

```yaml
# The $clusters_conf parameter.
ceph::clusters_conf:

  ceph:

    global_options:
      fsid: 'f875b4c1-535a-4f17-9883-2793079d410a'
      cluster_network: '192.168.22.0/24'
      public_network: '10.0.2.0/24'
      auth_cluster_required: 'cephx'
      auth_service_required: 'cephx'
      auth_client_required: 'cephx'
      filestore_xattr_use_omap: 'true'
      osd_pool_default_size: '2'
      osd_pool_default_min_size: '1'
      osd_pool_default_pg_num: '64'
      osd_pool_default_pgp_num: '64'
      osd_crush_chooseleaf_type: '1'
      osd_crush_update_on_start: 'false',
      osd_journal_size: '0'
      osd_max_backfills: '1'
      osd_recovery_max_active: '1'
      osd_client_op_priority: '63'
      osd_recovery_op_priority: '1'
      osd_op_threads: '4'
      mds_cache_size: '1000000'
      osd_scrub_begin_hour: '3'
      osd_scrub_end_hour: '5'
      mon_allow_pool_delete: 'false'
      mon_osd_down_out_subtree_limit: 'host'
      mon_osd_min_down_reporters: '4' # set to (#OSDs per node) + 1 is a good idea

    monitors:
      mon-1:
        id: 'ceph01'
        address: '10.0.2.150'
      mon-2:
        id: 'ceph02'
        address: '10.0.2.151'
      mon-3:
        id: 'ceph03'
        address: '10.0.2.152'

    keyrings:
      admin:
        key: 'AQBzfhRW3FU7BRAA75c8O7ZcJRwNMHrhLtSA3Q=='
        properties:
        - 'caps mon = "allow *"'
        - 'caps osd = "allow *"'
        - 'caps mds = "allow"'
      cephfs:
        key: 'AQB1fhRWkM5tFxAADYKzOgTbDZw9LEMgbPw4yw=='
        properties:
        - 'caps mon = "allow r"'
        - 'caps osd = "allow class-read object_prefix rbd_children, allow rwx pool=cephfsdata"'
        - 'caps mds = "allow"'
      radosgw.gw1:
        key: 'AQDofhRWBh/ZBBAAtaRA4J9VHl7srhYyxo5pig=='
        radosgw_host: 'radosgw-1'
        rgw_dns_name: 'rgw.domain.tld'
        properties:
        - 'caps mon = "allow rwx"'
        - 'caps osd = "allow rwx"'
      radosgw.gw2:
        key: 'AQDyfhRWdN50ARAATcfy7itnU1KyUKoX+XNi8g=='
        radosgw_host: 'radosgw-2'
        rgw_dns_name: 'rgw.domain.tld'
        properties:
        - 'caps mon = "allow rwx"'
        - 'caps osd = "allow rwx"'
      cinder:
        key: 'AQDzfhRWjOwnIRAA9OV8cFbwnLyQElQl2jPy6g=='
        owner: 'cinder'
        group: 'cinder'
        mode: '0640'
        properties:
        - 'caps mon = "allow r"'
        - 'caps osd = "allow class-read object_prefix rbd_children, allow rwx pool=volumes"'
```

And in the yaml file of the specific node (ie in `$fqdn.yaml`)
you can put:

```yaml
# The node will be a client node of the cluster and will use specific
# ceph accounts.
ceph::is_clientnode: true
ceph::client_accounts:
  ceph: [ 'cinder', 'cephfs' ]

# But the node will be a cluster node too.
ceph::is_clusternode: true
```




