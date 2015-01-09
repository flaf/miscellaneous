# User defined type to create ceph clusters. This module has
# been tested with Ceph Firefly (0.8.7) on Ubuntu Trusty.
#
# Warning 1: this module manages the installation of ceph
# but it doesn't manage the configuration of APT to be able
# to install the right version of Ceph. It's up to you to
# handle this part (with the ::apt Puppet module for
# instance).
#
# Warning 2: this module manages installation and configuration
# of files but no cluster will be up after run puppet. After
# puppet run on each node of the cluster, you should:
#
# 1. launch
#
#     /root/monitor_init.sh
#
# on the initial monitor node.
#
# 2. launch
#
#     /root/monitor_add.sh
#
# on each monitor node except the initial monitor node.
#
# 3. create the ceph accounts except the "admin" account
# which is already created (during the initialization
# of the monitor). For instance, to create the account
# "cinder" in the cluster "my_cluster", you can launch
#
#   ceph auth add client.cinder --cluster my_cluster \
#       -i /etc/ceph/my_cluster.client.cinder.keyring
#
# Normally, the file "/etc/ceph/my_cluster.client.cinder.keyring"
# already exists and contains the key and the capabilities
# of the account.
#
# Then, your cluster is up but without any OSD. It's up
# to you to manage OSD daemons (add or remove). You can
# installed OSDs with the command ceph_osd_add. Run:
#
#   ceph_osd_add --help
#
# to see the options. It's possible to add monitors with
# the command ceph_monitor_add (see the --help option too
# for more information).
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
# *osd_journal_size*:
# The size of the osd journal in megabytes. Must be at least
# 1024. This parameter is optional and the default value is 5120.
# A formula is proposed here [1].
#
#   osd journal size =
#       2 x ("expected throughput" x "filestore max sync interval")
#
# The default value of "filestore max sync interval" is 5 (see [2]).
# The "expected throughput" is ~100 MB/s for 7200 RPM disk (for instance).
# Take the minimum between the "expected throughput" of the disk and
# the "expected throughput" of the network.
#
# *osd_pool_default_size*:
# The default number of replicated objects when a pool is created.
# This parameter is optional and the default value is 2.
#
# *osd_pool_default_pg_num*:
# The default number of placement groups when a pool is
# created. The default value of this parameter is 256.
# How to choose this number? See [3].
# About the pgp_num, see [4].
#
# *magic_tag:*
# Keyrings and ceph configuration are exported in order to
# be imported by ceph clients. Keyrings are tagged with
# these strings: 'ceph-keyring', 'account' and the magic_tag
# (after expansion). The ceph configuration is tagged with
# 'ceph-conf' and the magic_tag (after expansion). This
# parameter is optional and the default value is
# "$cluster_name". A possible value for this parameter is
# '@datacenter-ceph' where @datacenter will be expanded (if
# the variable is defined).
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
# *keyrings:*
# This parameter must be a hash which represents keyrings.
# This parameter is optional and the default value is {},
# ie no keyring file is created. This parameter must have
# this structure:
#
#  {
#   'test1' => {
#               'key'      => 'AQBWX65UeDO/NRAAXWTEWvlvq2alpD5EEmZ7DA=='
#               properties => [
#                               'caps mon = "allow r"',
#                               'caps osd = " allow rwx pool=pool1"'
#                             ]
#              }
#   'test2' => {
#               'key'      => 'AQBVX65UsGEMIxAA/F5t/wuDtKvFD/5ZYdS0DA=='
#               properties => [
#                               'caps mon = "allow r"',
#                               'caps osd = " allow rwx pool=pool2"'
#                             ]
#              }
#  }
#
# The keys of this hash are the names of the accounts.
# You can generate a key with this command:
#
#     ceph-authtool --gen-print-key
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
# property means that this monitor will be the ceph cluster
# will initialized manually with the command /root/monitor_init.sh
# (see above).
# If the working directory of the monitor has a specific
# device, it's possible to provided the device name and
# the mount options.
#
# *admin_key*:
# The key (for authentification) of the ceph account "admin".
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
#  $keyrings = # the same hash as above.
#  $monitors = # the same hash as above.
#
#  ::ceph { 'my_cluster':
#     cluster_name    => 'test',
#     magic_tag       => '@datacenter-test',
#     monitors        => $monitors,
#     keyrings        => $keyrings,
#     admin_key       => 'AQC4yY5UcP5RNRAAG8tsOZPjrMmmlAjZ2b+1Jg==',
#     fsid            => '87dc2273-776f-4054-85dd-b746f0127433',
#     cluster_network => '10.0.0.0/24',
#     public_network  => '172.31.0.0/16',
#  }
#
# == Links
#
# [1] http://ceph.com/docs/next/rados/configuration/osd-config-ref/#journal-settings:
# [2] http://ceph.com/docs/master/rados/configuration/filestore-config-ref/#synchronization-intervals
# [3] http://ceph.com/docs/master/rados/operations/placement-groups/#a-preselection-of-pg-num
# [4] http://ceph.com/docs/master/rados/operations/placement-groups/#set-the-number-of-placement-groups
#
define ceph::cluster (
  $cluster_name            = 'ceph',
  $osd_journal_size        = '5120',
  $osd_pool_default_size   = '2',
  $osd_pool_default_pg_num = '256',
  $magic_tag               = $cluster_name,
  $cluster_network         = undef,
  $public_network          = undef,
  $keyrings                = {},
  $monitors,
  $admin_key,
  $fsid,
) {

  case $::lsbdistcodename {
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  validate_string(
    $cluster_name,
    $osd_journal_size,
    $osd_pool_default_size,
    $osd_pool_default_pg_num,
    $magic_tag,
    $admin_key,
    $fsid,
  )

  $tag_expanded = inline_template(str2erb($magic_tag))

  validate_hash($keyrings)
  validate_hash($monitors)

  if $public_network and ! $cluster_network {
    fail("Class ${title} problem, plubic_network and cluster_network must \
be defined together.")
  }
  if ! $public_network and $cluster_network {
    fail("Class ${title} problem, plubic_network and cluster_network must \
be defined together.")
  }

  if $public_network and $cluster_network {
    validate_string(
      $public_network,
      $cluster_network,
    )
  }

  # Internal variables.
  $mon_init = strip(inline_template('
    <%-
      c = 0
      mons = @monitors
      monitor = ""
      mons.each do |mon, params|
        if params.has_key?("initial") and params["initial"] == true
          monitor = mon
          c += 1
        end
      end

      if c == 0
        scope.function_fail([ "Initial monitor not found." ])
      elsif c > 1
        scope.function_fail([ "Several initial monitors found. " +
                              "Initial monitor must be unique." ])
      end
    -%>
    <%= monitor %>
  '))

  # Define $is_monitor and $is_monitor_init.
  if has_key($monitors, $::hostname) {
    $is_monitor = true
    if has_key($monitors[$::hostname], 'initial') {
      $is_monitor_init = true
    } else {
      $is_monitor_init = false
    }
  } else {
    $is_monitor      = false
    $is_monitor_init = false
  }

  require '::ceph::cluster::packages'
  require '::ceph::cluster::scripts'
  require '::ceph::common::ceph_dir'

  # Keyring for client.admin.
  ::ceph::cluster::keyring { "${cluster_name}.client.admin":
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

  ##################################
  ### Scripts to start monitors ####
  ##################################

  if $is_monitor {

    $mon_init_addr = $monitors[$mon_init]['address']
    $id            = $monitors[$::hostname]['id']

    $opt_base = "--cluster '$cluster_name' --id '$id' -m '$mon_init_addr'"

    if has_key($monitors[$::hostname], 'device') and
    has_key($monitors[$::hostname], 'mount_options') {
      $device         = $monitors[$::hostname]['device']
      $mount_options  = $monitors[$::hostname]['mount_options']
      $opt_device     = "--device '$device' --mount-options '$mount_options' --yes"
    } else {
      $device_options = ''
    }

    if $is_monitor_init {

      # The file must be exported.
      @@file { "ceph-conf-${cluster_name}-${::fqdn}":
        path    => "/etc/ceph/${cluster_name}.conf",
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('ceph/ceph.conf.erb'),
        tag     => [ 'ceph-conf', $tag_expanded ], # tag for clients.
      }

      # And the file must be put in the host.
      File <<| title == "ceph-conf-${cluster_name}-${::fqdn}" |>> {}

      file { '/root/monitor_init.sh':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0750',
        content => "#!/bin/sh\nceph_monitor_init $opt_base $opt_device\n",
      }

    } else {

      file { "ceph-conf-${cluster_name}-${::fqdn}":
        path    => "/etc/ceph/${cluster_name}.conf",
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('ceph/ceph.conf.erb'),
      }

      file { '/root/monitor_add.sh':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0750',
        content => "#!/bin/sh\nceph_monitor_add $opt_base $opt_device\n",
      }

    }
  }

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
          hash[cluster_name + ".client." + account] = {
            "cluster_name" => cluster_name,
            "account"      => account,
            "key"          => p["key"],
            "properties"   => p["properties"],
          }
        end
      -%>
      <%= hash.to_s %>'
    ))
  }

  if $keyrings_hash {

    if $is_monitor_init {

      $default = {
        'exported'  => true,
        'magic_tag' => $tag_expanded,
      }

      create_resources('::ceph::cluster::keyring', $keyrings_hash, $default)
      File <<|     tag == 'ceph-keyring'
               and tag == $tag_expanded
               and tag == 'ceph::cluster::keyring' |>> {}

    } else {

      create_resources('::ceph::cluster::keyring', $keyrings_hash)

    }

  }

}


