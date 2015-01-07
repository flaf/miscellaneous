# TODO: rewrite doc header.
#
# User defined type to create Ceph clusters. This module has
# been tested with Ceph Firefly (0.8.7) on Ubuntu Trusty.
#
# Warning 1: this module manages the installation of ceph
# but it doesn't manage the configuration of APT to be able
# to install the right version of Ceph. It's up to you to
# handle this part (with the ::apt Puppet module for
# instance).
#
# Warning 2: you should run puppet on the host which is
# declared the "initial" monitor via the parameters. And,
# after, you can run puppet on the other hosts.
#
# Normally, after the puppet run, monitors will be installed
# and osds will not. You can installed osds with the command
# ceph_osd_add. Run:
#
#   ceph_osd_add --help
#
# to see the options. It's possible to add monitors with
# the command ceph_monitor_add (see the --help option too
# for more information).
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
define ceph::cluster (
  $cluster_name            = 'ceph',
  $osd_journal_size        = '5120',
  $osd_pool_default_size   = '2',
  $osd_pool_default_pg_num = '256',
  $magic_tag               = $cluster_name,
  $cluster_network         = undef,
  $public_network          = undef,
  $keyrings                = undef,
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

  validate_hash($monitors)

  if $keyrings {
    validate_hash($keyrings)
  }

  if $public_network and ! $cluster_network {
    fail("Class ${title} problem, plubic_network and cluster_network must \
be defined together.")
  }
  if ! $public_network and $cluster_network {
    fail("Class ${title} problem, plubic_network and cluster_network must \
be defined together.")
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

      file { '/root/monitor_init.sh':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0750',
        content => "#!/bin/sh\nceph_monitor_init $opt_base $opt_device\n",
      }

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

  if $keyrings {

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
      File <<| tag == $tag_expanded and tag == 'ceph::cluster::keyring' |>> {}

    } else {

      create_resources('::ceph::cluster::keyring', $keyrings_hash)

    }

  }

}


