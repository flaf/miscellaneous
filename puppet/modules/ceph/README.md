# Module description

This module allows to manage Ceph clusters and Ceph clients.




# Warning 1: you must create the cluster yourself

This module manages installation and configuration of files
but no cluster will be up after a run puppet. After a puppet
run on each node of the cluster, you should typically
launch:

```sh
# 1. If you have dedicated disks for monitors or osds,
#    you must create partitions (use `gdisk`) and
#    you must format these partitions on each node.
#    Use `gdisk`, create a part-label for each partition
#    and use the symlinks in `/dev/disk/by-partlabel/`.
#    (ie use gdisk to set a part-label for each partition).


# Typically, /dev/sdd1 is used for the journal. Or, better,
# the journal is in a raw partition in another disk (ideally
# a SSD).
mkfs.xfs -L osd-0 -f /dev/sdd2
mkfs.xfs -L osd-1 -f /dev/sde2
# Etc...


# 2. Installation of the all monitors on each node.
#
# For the ID of monitors and mds, don't use a numeric IDs
# but systematically _alphanumeric_ IDs.
#
# For the first monitor.
ceph-monitor-init --device /dev/disk/by-partlabel/mon-ceph01   \
                  --mount-options noatime,defaults --id ceph01 \
                  --monitor-addr "$address_mon_1"
#
# For the other monitors.
ceph-monitor-add --device /dev/disk/by-partlabel/mon-ceph01   \
                 --mount-options noatime,defaults --id ceph02 \
                 --monitor "$address_mon_1"
# Etc...


# 3. Installation of the ods on each node (help with ceph-osd-add --help).
ceph-osd-add --device /dev/disk/by-partlabel/osd-0  \
             --mount-options noatime,defaults --yes \
             --journal /dev/disk/by-partlabel/osd-0-journal
ceph-osd-add --device /dev/disk/by-partlabel/osd-7  \
             --mount-options noatime,defaults --yes \
             --weight 4.0 --osd-id 7                \
             --journal /dev/disk/by-partlabel/osd-7-journal
# Etc...

# 4. On a specific node, we create the ceph accounts.
ceph auth add client.foo1 -i /etc/ceph/ceph.client.foo1.keyring
ceph auth add client.foo2 -i /etc/ceph/ceph.client.foo2.keyring
# Etc...

# 5. Installation of a cephfs if it's necessary.
# First, on each mds node (help with ceph-mds-add --help).
ceph-mds-add --id ceph01
ceph-mds-add --id ceph02
# Etc...
#
# Creation of the Cephfs.
ceph osd pool create data $pg_num_data
ceph osd pool create metadata $pg_num_metadata
ceph fs new cephfs metadata data
ceph fs ls # To check if all is OK.
```


# Warning 2 : journals have to be a GPT partition with a specific partlabel

If the journal is not a standard file in the OSD working
directory but a symlink to a raw partition, the partition
has to be a GPT partition with this pattern for the part-label:
`osd-*-journal`. Indeed, since Infernalis, the OSD daemons use
the dedicated `ceph` Unix account and the journal must have
this account as owner (without that the OSD daemon just can't
start). This puppet module put a udev rule so that `ceph` is
automatically the owner of each GPT partition whose part-label
matches this pattern `osd-*-journal` (where typically `*`
matches a number).

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
should configure this file with another puppet class (or
manually).




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
      'caps osd = "allow class-read object_prefix rbd_children, allow rwx pool=data"',
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
        - 'caps osd = "allow class-read object_prefix rbd_children, allow rwx pool=data"'
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




