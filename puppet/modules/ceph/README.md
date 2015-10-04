# The defined resource `ceph::clusternode`

It's a defined type to manage a Ceph cluster node.


## Warning

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
                 --monitor-addr "$address_mon_1"
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


## Parameters of the defined resource `ceph::clusternode`

The `cluster_name` parameter is a non-empty string which
represents the name of the cluster. This parameter is
optional and the default value is `"ceph"`.

`rgw_dns_name`:
If the cluster has rados gateway clients in the keyrings
parameter, this parameter allows to define the entry
"rgw dns name" in the `[client.<radosgw-id>]` sections.
This parameter is optional and the default value is undef,
and in this case the parameter is not defined.
If the cluster has no rados gateway client, this parameter
is useless.

*keyrings*:
This parameter must be a hash which represents keyrings.
This parameter is optional and the default value is {},
ie no keyring file is created. This parameter must have
this structure:

 { 'test1'       => { 'key'          => 'AQBWX65UeDO/NRAAXWTEWvlvq2alpD5EEmZ7DA==',
                      'properties'   => [ 'caps mon = "allow r"',
                                        'caps osd = " allow rwx pool=pool1"',
                                        ],
                    },
   'radosgw.gw1' => { 'key'          => 'AQBVX65UsGEMIxAA/F5t/wuDtKvFD/5ZYdS0DA==',
                      'properties'   => [ 'caps mon = "allow rwx"',
                                        'caps osd = " allow rwx"',
                                        ],
                      'radosgw_host' => 'radosgw-1',
                    },
 }

The keys of this hash are the names of the accounts.
The `radosgw_host` key means that the keyring is a specific
radosgw keyring and the value of this key must be the hostname
of the radosgw server.

You can generate a key with this command:

    apt-get install ceph-common && ceph-authtool --gen-print-key

*monitors*:
This parameter is mandatory. This parameter must be
a hash with this form:

   { 'ceph-node1' => { 'id'            => '1',
                       'address'       => '172.31.10.1',
                     },
     'ceph-node2' => { 'id'            => '2',
                       'address'       => '172.31.10.2',
                     },
     'ceph-node3' => { 'id'            => '3',
                       'address'       => '172.31.10.3',
                     },
   }

The keys are the hostnames of the monitors.

*admin_key*:
The key (for authentication) of the ceph account "admin".
This parameter is mandatory. This parameter should not
be present in clear text in Puppet/hiera etc.
You can generate such key with this command:

  ceph-authtool --gen-print-key

*global_options*:
This parameter is mandatory. This parameter must be
a hash where keys/values will be the parameters in
the `[global]` section of the of the /etc/ceph/$cluster.conf
file. Here is an example:

 { 'auth_client_required'      => 'cephx',
   'auth_cluster_required'     => 'cephx',
   'auth_service_required'     => 'cephx',
   'cluster network'           => '192.168.0.0/24',
   'public network'            => '10.0.2.0/24',
   'filestore_xattr_use_omap'  => 'true',
   'fsid'                      => '49276091-877c-464d-9e4d-23786db82fc8',
   'osd_crush_chooseleaf_type' => '1',
   'osd_journal_size'          => '2048',
   'osd_pool_default_min_size' => '1',
   'osd_pool_default_pg_num'   => '512',
   'osd_pool_default_pgp_num'  => '512',
   'osd_pool_default_size'     => '2',
 }

The fsid can be generated with this command:

  uuidgen

== Sample Usages

 $keyrings       = # the same hash as above.
 $monitors       = # the same hash as above.
 $global_options = # the same hash as above.

 ::ceph { 'my_cluster':
    cluster_name   => 'ceph-test',
    rgw_dns_name   => 's3store',
    keyrings       => $keyrings,
    monitors       => $monitors,
    global_options => $global_options,
 }

== Links

[1] OSD journal size:
http://ceph.com/docs/next/rados/configuration/osd-config-ref/#journal-settings:
http://ceph.com/docs/master/rados/configuration/filestore-config-ref/#synchronization-intervals

[2] pg_num and pgp_num (important):
http://ceph.com/docs/master/rados/operations/placement-groups/#a-preselection-of-pg-num
http://ceph.com/docs/master/rados/operations/placement-groups/#set-the-number-of-placement-groups





