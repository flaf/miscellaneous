# User defined type used by a ceph client to import:
# 1. The $cluster.conf file (if not already done).
# 2. The keyring of a specific ceph account.
#
# == Requirement/Dependencies
#
# Depends on homemade_functions module.
#
# == Parameters
#
# *cluster_name*:
# The name of the cluster. This parameter is optional and
# the default value is "ceph".
#
# *magic_tag:*
# Keyrings and ceph configuration are exported by the server
# in order to be imported by ceph clients. These files are
# tagged by the server. One of these tags is the magic tag
# (after expansion). This parameter allows you to specify
# exactly which cluster that you wish to import the keyring
# file (because you can have several clusters called "ceph"
# in your datacenter etc). A possible value for this parameter
# is (for instance) '@datacenter-ceph' where @datacenter will
# be expanded (if the variable is defined). This parameter
# is optional and the default value is $cluster_name.
#
# *owner:*
# The owner of the keyring file which will be imported.
# This parameter is optional and the default value is 'root'.
#
# *group:*
# The group of the keyring file which will be imported.
# This parameter is optional and the default value is 'root'.
#
# *mode:*
# The rights of the keyring file which will be imported.
# This parameter is optional and the default value is '0600'.
#
# *account:*
# The name of the ceph account whose the keyring file is
# imported. This parameter is mandatory and has no default
# value. This is a implementation detail, but for a radosgw
# (which is a particular ceph client), the value of this
# parameter must not be the account name but the hostname
# of the radosgw himself.
#
# == Sample Usages
#
#  ::ceph::client { 'ceph-cinder':
#    account      => 'cinder',
#    cluster_name => 'ceph',
#    magic_tag    => '@datacenter-ceph',
#    owner        => 'cinder',
#    mode         => '0640',
#  }
#
#
define ceph::client (
  $cluster_name        = 'ceph',
  $owner               = 'root',
  $group               = 'root',
  $mode                = '0600',
  $account,
  $key,
  $properties,
  $global_options,
  $monitors,
  $is_radosgw          = false,
  $common_rgw_dns_name = undef,
  $admin_email         = "root@{$::fqdn}",
) {

  require '::ceph::client::packages'
  require '::ceph::common::ceph_dir'

  validate_string(
    $cluster_name,
    $owner,
    $group,
    $mode,
    $account,
    $key,
    $mail_admin,
  )

  validate_array($properties)

  validate_hash(
    $global_options,
    $monitors,
  )

  validate_bool($is_radosgw)

  if $is_radosgw {
    if $common_rgw_dns_name != undef {
      validate_string($common_rgw_dns_name)
    }
    validate_string($admin_email)
  }

  unless has_key($global_options, 'fsid') {
    fail("Class ${title} problem, the `global_options` hash must have \
the 'fsid' key.")
  }

  # Maybe the current node is server too. Or maybe
  # the current node is client of this cluster with
  # several ceph account. In these cases, the file
  # is already defined.
  if !defined(File["/etc/ceph/${cluster_name}.conf"]) {
    # Configuration file of the cluster.
    file { "/etc/ceph/${cluster_name}.conf":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('ceph/ceph.conf.erb'),
    }
  }

  ::ceph::common::keyring { "${cluster_name}.client.${account}.keyring":
    cluster_name => $cluster_name,
    account      => $account,
    key          => $key,
    properties   => $properties,
    owner        => $owner,
    group        => $group,
    mode         => $mode,
  }

  if $is_radosgw {

    ::ceph::radosgw { "${cluster_name}-${account}":
      cluster_name        => $cluster_name,
      account             => $account,
      admin_email         => $admin_email,
      common_rgw_dns_name => $common_rgw_dns_name,
    }

  }

}


