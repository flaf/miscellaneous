# User defined type to create ceph clusters.
#
# Warning 1: this module manages the installation of ceph
# but it doesn't manage the configuration of APT to be able
# to install the right version of Ceph. It's up to you to
# handle this part (with the ::apt Puppet module for instance).
#
# Warning 2: this module manages installation and configuration
# of files but no cluster will be up after run puppet. After
# puppet run on each node of the cluster, you should typically
# launch:
#
#    # 1. If you have dedicated disks for monitors or osds,
#    #    you must format the partitions on each node.
#    #    Use gdisk and use /dev/disk/by-partlabel/ symlinks.
#    mkfs.xfs -L OSD0 -f /dev/sdd2 # typically, /dev/sdd1 is used for the journal.
#    mkfs.xfs -L OSD1 -f /dev/sde2 # typically, /dev/sde1 is used for the journal.
#    # Etc.
#
#    # 2. Installation of the all monitors on each node.
#    ceph-monitor-init --device /dev/disk-by-partlabel/mon-1   \
#                      --mount-options noatime,defaults --id 1 \
#                      --monitor-addr <address-mon-1>
#    ceph-monitor-add --device /dev/disk-by-partlabel/mon-2   \
#                     --mount-options noatime,defaults --id 1 \
#                     --monitor-addr <address-mon-1>
#    # Etc.
#
#    # 3. Installation of the ods on each node (help with ceph-osd-add --help).
#    ceph-osd-add --device /dev/disk-by-partlabel/osd-0  \
#                 --mount-options noatime,defaults --yes \
#                 --journal /dev/disk/by-partlabel/osd-0-journal
#    ceph-osd-add --device /dev/disk-by-partlabel/osd-1  \
#                 --mount-options noatime,defaults --yes \
#                 --journal /dev/disk/by-partlabel/osd-1-journal
#    # Etc.
#
#    # 4. On a specific node, we create the ceph account.
#    ceph auth add client.foo1 -i /etc/ceph/ceph.client.foo1.keyring
#    ceph auth add client.foo2 -i /etc/ceph/ceph.client.foo2.keyring
#    # Etc.
#
#    # 5. On each node, we install the mds service.
#    ceph-mds-add --id 1
#    ceph-mds-add --id 2
#    # Etc.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib and homemade_functions modules.
#
# == Parameters
#
# *cluster_name*:
# The name of the cluster. This parameter is optional and
# the default value is "ceph".
#
# *rgw_dns_name*:
# If the cluster has rados gateway clients in the keyrings
# parameter, this parameter allows to define the entry
# "rgw dns name" in the `[client.<radosgw-id>]` sections.
# This parameter is optional and the default value is undef,
# and in this case the parameter is not defined.
# If the cluster has no rados gateway client, this parameter
# is useless.
#
# *keyrings*:
# This parameter must be a hash which represents keyrings.
# This parameter is optional and the default value is {},
# ie no keyring file is created. This parameter must have
# this structure:
#
#  { 'test1'       => { 'key'          => 'AQBWX65UeDO/NRAAXWTEWvlvq2alpD5EEmZ7DA==',
#                       'properties'   => [ 'caps mon = "allow r"',
#                                         'caps osd = " allow rwx pool=pool1"',
#                                         ],
#                     },
#    'radosgw.gw1' => { 'key'          => 'AQBVX65UsGEMIxAA/F5t/wuDtKvFD/5ZYdS0DA==',
#                       'properties'   => [ 'caps mon = "allow rwx"',
#                                         'caps osd = " allow rwx"',
#                                         ],
#                       'radosgw_host' => 'radosgw-1',
#                     },
#  }
#
# The keys of this hash are the names of the accounts.
# The `radosgw_host` key means that the keyring is a specific
# radosgw keyring and the value of this key must be the hostname
# of the radosgw server.
#
# You can generate a key with this command:
#
#     apt-get install ceph-common && ceph-authtool --gen-print-key
#
# *monitors*:
# This parameter is mandatory. This parameter must be
# a hash with this form:
#
#    { 'ceph-node1' => { 'id'            => '1',
#                        'address'       => '172.31.10.1',
#                      },
#      'ceph-node2' => { 'id'            => '2',
#                        'address'       => '172.31.10.2',
#                      },
#      'ceph-node3' => { 'id'            => '3',
#                        'address'       => '172.31.10.3',
#                      },
#    }
#
# The keys are the hostnames of the monitors.
#
# *admin_key*:
# The key (for authentication) of the ceph account "admin".
# This parameter is mandatory. This parameter should not
# be present in clear text in Puppet/hiera etc.
# You can generate such key with this command:
#
#   ceph-authtool --gen-print-key
#
# *global_options*:
# This parameter is mandatory. This parameter must be
# a hash where keys/values will be the parameters in
# the `[global]` section of the of the /etc/ceph/$cluster.conf
# file. Here is an example:
#
#  { 'auth_client_required'      => 'cephx',
#    'auth_cluster_required'     => 'cephx',
#    'auth_service_required'     => 'cephx',
#    'cluster network'           => '192.168.0.0/24',
#    'public network'            => '10.0.2.0/24',
#    'filestore_xattr_use_omap'  => 'true',
#    'fsid'                      => '49276091-877c-464d-9e4d-23786db82fc8',
#    'osd_crush_chooseleaf_type' => '1',
#    'osd_journal_size'          => '2048',
#    'osd_pool_default_min_size' => '1',
#    'osd_pool_default_pg_num'   => '512',
#    'osd_pool_default_pgp_num'  => '512',
#    'osd_pool_default_size'     => '2',
#  }
#
# The fsid can be generated with this command:
#
#   uuidgen
#
# == Sample Usages
#
#  $keyrings       = # the same hash as above.
#  $monitors       = # the same hash as above.
#  $global_options = # the same hash as above.
#
#  ::ceph { 'my_cluster':
#     cluster_name   => 'ceph-test',
#     rgw_dns_name   => 's3store',
#     keyrings       => $keyrings,
#     monitors       => $monitors,
#     global_options => $global_options,
#  }
#
# == Links
#
# [1] OSD journal size:
# http://ceph.com/docs/next/rados/configuration/osd-config-ref/#journal-settings:
# http://ceph.com/docs/master/rados/configuration/filestore-config-ref/#synchronization-intervals
#
# [2] pg_num and pgp_num (important):
# http://ceph.com/docs/master/rados/operations/placement-groups/#a-preselection-of-pg-num
# http://ceph.com/docs/master/rados/operations/placement-groups/#set-the-number-of-placement-groups
#
define ceph::cluster (
  $cluster_name = 'ceph',
  $rgw_dns_name = undef,
  $keyrings     = {},
  $monitors,
  $admin_key,
  $global_options,
) {

  case $::lsbdistcodename {
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  validate_string(
    $cluster_name,
    $admin_key,
  )

  validate_hash(
    $keyrings,
    $monitors,
    $global_options,
  )

  unless has_key($global_options, 'fsid') {
    fail("Class ${title} problem, the `global_options` hash must have \
the 'fsid' key.")
  }

  if $rgw_dns_name != undef {
    validate_string($rgw_dns_name)
  }

  # Define initial monitor and its address.
  # Make directly "sort(keys($h))[0]" raises a syntax error.
  $array_tmp     = sort(keys($monitors))
  $mon_init      = $array_tmp[0] # the initial monitor is the first.
  $mon_init_addr = $monitors[$mon_init]['address']

  # id of the current host.
  $id            = $monitors[$::hostname]['id']

  # Define $is_monitor.
  if has_key($monitors, $::hostname) {
    $is_monitor = true
  } else {
    $is_monitor = false
  }

  # Define $is_monitor_init.
  if $mon_init == $::hostname {
    $is_monitor_init = true
  } else {
    $is_monitor_init = false
  }

  require '::ceph::cluster::packages'
  require '::ceph::cluster::scripts'
  require '::ceph::common::ceph_dir'

  # Keyring for client.admin.
  ::ceph::common::keyring { "${cluster_name}.client.admin":
    cluster_name => $cluster_name,
    account      => 'admin',
    key          => $admin_key,
    properties   => [
                      'auid = 0',
                      'caps mds = "allow"',
                      'caps mon = "allow *"',
                      'caps osd = "allow *"',
                    ],
  }

  # Configuration file of the cluster.
  file { "/etc/ceph/${cluster_name}.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ceph/ceph.conf.erb'),
  }

  #
  # In fact, this part is completely useless (bad idea).
  #
  ##################################
  ### Scripts to start monitors ####
  ##################################

  #if $is_monitor {

  #  $opt_base = "--cluster '$cluster_name' --id '$id' -m '$mon_init_addr'"

  #  if has_key($monitors[$::hostname], 'device') and
  #  has_key($monitors[$::hostname], 'mount_options') {
  #    $device         = $monitors[$::hostname]['device']
  #    $mount_options  = $monitors[$::hostname]['mount_options']
  #    $opt_device     = "--device '$device' --mount-options '$mount_options' --yes"
  #  } else {
  #    $device_options = ''
  #  }

  #  if $is_monitor_init {

  #    file { '/root/monitor-init.sh':
  #      ensure  => present,
  #      owner   => 'root',
  #      group   => 'root',
  #      mode    => '0750',
  #      content => "#!/bin/sh\nceph-monitor-init $opt_base $opt_device\n",
  #    }

  #  } else {

  #    file { '/root/monitor-add.sh':
  #      ensure  => present,
  #      owner   => 'root',
  #      group   => 'root',
  #      mode    => '0750',
  #      content => "#!/bin/sh\nceph-monitor-add $opt_base $opt_device\n",
  #    }

  #  }

  #}

  ################
  ### Keyrings ###
  ################

  unless empty($keyrings) {

    $keyrings_hash = str2hash(inline_template('
      <%-
        hash = {}
        keyrings = @keyrings
        cluster_name = @cluster_name
        keyrings.each do |account,p|
          name = cluster_name + ".client." + account
          hash[name] = {
            "cluster_name" => cluster_name,
            "account"      => account,
            "key"          => p["key"],
            "properties"   => p["properties"],
          }
          optional_keys = [ "owner", "group", "mode" ]
          optional_keys.each do |k|
            if p.has_key?(k)
              hash[name][k] = p[k]
            end
          end
        end
      -%>
      <%= hash.to_s %>'
    ))
  }

  if $keyrings_hash {

    create_resources('::ceph::common::keyring', $keyrings_hash)

  }

}


