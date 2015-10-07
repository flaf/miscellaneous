# Module description

This module allows to manage Ceph clusters and Ceph clients.




# Warning

This module manages installation and configuration of files
but no cluster will be up after a run puppet. After a puppet
run on each node of the cluster, you should typically
launch:

```sh
# 1. If you have dedicated disks for monitors or osds,
#    you must format the partitions on each node.
#    Use gdisk and use /dev/disk/by-partlabel/ symlinks.
mkfs.xfs -L OSD0 -f /dev/sdd2 # typically, /dev/sdd1 is used for the journal.
mkfs.xfs -L OSD1 -f /dev/sde2 # typically, /dev/sde1 is used for the journal.
# Etc...


# 2. Installation of the all monitors on each node.
#
# For the first monitor.
ceph-monitor-init --device /dev/disk-by-partlabel/mon-1   \
                  --mount-options noatime,defaults --id 1 \
                  --monitor-addr "$address_mon_1"
#
# For the other monitors.
ceph-monitor-add --device /dev/disk-by-partlabel/mon-2   \
                 --mount-options noatime,defaults --id 1 \
                 --monitor "$address_mon_1"
# Etc...


# 3. Installation of the ods on each node (help with ceph-osd-add --help).
ceph-osd-add --device /dev/disk-by-partlabel/osd-0  \
             --mount-options noatime,defaults --yes \
             --journal /dev/disk/by-partlabel/osd-0-journal
ceph-osd-add --device /dev/disk-by-partlabel/osd-1  \
             --mount-options noatime,defaults --yes \
             --journal /dev/disk/by-partlabel/osd-1-journal
# Etc...


# 4. On a specific node, we create the ceph accounts.
ceph auth add client.foo1 -i /etc/ceph/ceph.client.foo1.keyring
ceph auth add client.foo2 -i /etc/ceph/ceph.client.foo2.keyring
# Etc...


# 5. On each node, we install the mds service.
ceph-mds-add --id 1
ceph-mds-add --id 2
# Etc...
```




# Usage

Here is an example:

```puppet
$ceph_global_conf = {
  'fsid'                      => 'f875b4c1-535a-4f17-9883-2793079d410a',
  'cluster_network'           => '192.168.22.0/24',
  'public_network'            => '10.0.2.0/24',
  'auth_cluster_required'     => 'cephx',
  'auth_service_required'     => 'cephx',
  'auth_client_required'      => 'cephx',
  'filestore_xattr_use_omap'  => 'true',
  'osd_pool_default_size'     => '2',
  'osd_pool_default_min_size' => '1',
  'osd_pool_default_pg_num'   => '64',
  'osd_pool_default_pgp_num'  => '64',
  'osd_crush_chooseleaf_type' => '1',
  'osd_journal_size'          => '0',
  'osd_max_backfills'         => '1',
  'osd_recovery_max_active'   => '1',
  'osd_client_op_priority'    => '63',
  'osd_recovery_op_priority'  => '1',
  'osd_op_threads'            => '4',
  'mds_cache_size'            => '1000000',
  'osd_scrub_begin_hour'      => '3',
  'osd_scrub_end_hour'        => '5',
  'mon_allow_pool_delete'     => 'false',
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
    'monitors'       => { 'mon-1' => {'id' => '0', 'address' => '10.0.2.150'},
                          'mon-2' => {'id' => '1', 'address' => '10.0.2.151'},
                          'mon-3' => {'id' => '2', 'address' => '10.0.2.152'},
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
  clusters_conf     => $clusters_conf,
  client_accounts   => $client_accounts,
  force_clusternode => true,
}
```


