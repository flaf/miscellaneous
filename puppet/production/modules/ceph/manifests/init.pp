# User defined type to create Ceph clusters.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib.
#
# == Parameters
#
# *cluster_name*:
# The name of the cluster. The default value is "ceph".
#
# *osd_journal_size*:
# The size of the osdjournal in megabytes. Must be at least 1024.
# The default value of this parameter is 5120.
# A formula is proposed here
# http://ceph.com/docs/next/rados/configuration/osd-config-ref/#journal-settings:
#
#   osd journal size = 2 x ("expected throughput" x "filestore max sync interval")
#
# The default value of "filestore max sync interval" is 5
# (http://ceph.com/docs/master/rados/configuration/filestore-config-ref/#synchronization-intervals)
# The "expected throughput" is ~100 MB/s for 7200 RPM disk (for instance).
# Take the minimum between the "expected throughput" of the disk and the
# "expected throughput" of the network.
#
# *osd_pool_default_size*:
# The default number of replicated objects when a pool is created.
# The default value of this parameter is 2.
#
# *osd_pool_default_pg_num*:
# The default number of placement groups when a pool is
# created. The default value of this parameter is 256.
# How to choose this number? See:
#
#   http://ceph.com/docs/master/rados/operations/placement-groups/#a-preselection-of-pg-num
#
# About the pgp_num:
#
#   http://ceph.com/docs/master/rados/operations/placement-groups/#set-the-number-of-placement-groups
#
# *cluster_network*:
# The CIDR network address of the OSDs for replication of
# data between OSDs, data balancing, data restoration etc.
# If you define this parameter, you must define the
# public_network parameter too. The default value of
# cluster_network is undef (no cluster network, the same
# network is used for the cluster and for the ceph clients.
#
# *public_network*:
# The CIDR network address of the OSDs for the traffic with
# ceph clients. The default value of this parameter is
# undef. If you define this parameter, you must define the
# cluster_network parameter too.
# Note: the monitors should be in the public network because
# ceph clients communicates with them.
#
# *monitors*:
# A hash with this form:
#
#    { 'ceph-node1' => { 'id'            => '1',
#                        'address'       => '172.31.10.1',
#                        'initial'       => true,
#                      },
#      'ceph-node2' => { 'id'            => '2',
#                        'address'       => '172.31.10.2',
#                        'device'        => '/dev/sdb1',
#                        'mount_options' => 'noatime,defaults',
#                      },
#      'ceph-node3' => { 'id'            => '3',
#                        'address'       => '172.31.10.3',
#                      },
#    }
#
# The keys are the hostnames of the monitors. The "initial"
# property means that this monitor will be the first monitor
# installed which will create the Ceph cluster.
# If the working directory of the monitor has a specific
# device, it's possible to provided the device name and
# the mount options.
#
# *admin_key*:
# The key (for authentification) of the ceph account "client.admin".
# This parameter has no default value. This parameter should not
# be present in clear text in Puppet/hiera etc.
# You can generate such key with this command:
#
#   ceph-authtool --gen-print-key
#
# *fsid*:
# The fsid of the cluster. This parameter has no default value.
# You can generate such fsid with this command:
#
#   uuidgen
#
# == Sample Usages
#
#  $monitors = # the same hash as above.
#
#  ::ceph { 'my_cluster':
#     cluster_name => 'test',
#     monitors     => $monitors,
#     admin_key    => 'AQC4yY5UcP5RNRAAG8tsOZPjrMmmlAjZ2b+1Jg==',
#     fsid         => '87dc2273-776f-4054-85dd-b746f0127433',
#  }
#
define ceph (
  $cluster_name            = 'ceph',
  $osd_journal_size        = '5120',
  $osd_pool_default_size   = '2',
  $osd_pool_default_pg_num = '256',
  $cluster_network         = undef,
  $public_network          = undef,
  $monitors,
  $admin_key,
  $fsid,
) {

  validate_string(
    $cluster_name,
    $osd_journal_size,
    $osd_pool_default_size,
    $osd_pool_default_pg_num,
    $admin_key,
    $fsid,
  )
  validate_hash($monitors)

  if $public_network and ! $cluster_network {
    fail("Class ${title} problem, plubic_network and cluster_network must \
be defined together.")
  }
  if ! $public_network and $cluster_network {
    fail("Class ${title} problem, plubic_network and cluster_network must \
be defined together.")
  }

  # Internal variables.
  $mon_init      = get_monitor_init_($monitors)
  $mon_init_addr = $monitors[$mon_init]['address']
  $id            = $monitors[$::hostname]['id']

  require '::ceph::packages'
  require '::ceph::scripts'

  file { "/etc/ceph/${cluster_name}.client.admin.keyring":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('ceph/ceph.client.admin.keyring.erb'),
  }

  file { "/etc/ceph/${cluster_name}.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ceph/ceph.conf.erb'),
    notify  => Exec['restart-ceph-all'],
  }

  exec { "restart-ceph-all":
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => "restart ceph-all",
    user        => 'root',
    group       => 'root',
    refreshonly => true,
  }

  #############################
  ### Starting of monitors ####
  #############################

  $opt_base = "--cluster '$cluster_name' --id '$id' -m '$mon_init_addr'"

  if has_key($monitors[$::hostname], 'device') and
  has_key($monitors[$::hostname], 'mount_options') {

    $device        = $monitors[$::hostname]['device']
    $mount_options = $monitors[$::hostname]['mount_options']
    $opt_device    = "--device '$device' --mount-options '$mount_options' --yes"

  } else {

    $device_options = ''

  }

  if has_key($monitors, $::hostname) {

    if has_key($monitors[$::hostname], 'initial') {

      exec { "monitor-init-${cluster_name}":
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin',
        command => "ceph_monitor_init $opt_base $opt_device",
        user    => 'root',
        group   => 'root',
        onlyif  => "ceph_monitor_init $opt_base $opt_device --test",
        require => [
                     File["/etc/ceph/${cluster_name}.conf"],
                     File["/etc/ceph/${cluster_name}.client.admin.keyring"],
                     Exec['restart-ceph-all'],
                   ],
      }

    } else {

      exec { "monitor-add-${cluster_name}":
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin',
        command => "ceph_monitor_add $opt_base $opt_device",
        user    => 'root',
        group   => 'root',
        onlyif  => "ceph_monitor_add $opt_base $opt_device --test",
        require => [
                     File["/etc/ceph/${cluster_name}.conf"],
                     File["/etc/ceph/${cluster_name}.client.admin.keyring"],
                     Exec['restart-ceph-all'],
                   ],
      }

    }
  }

}


