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
# String which gives the name of the ceph account.
# This parameter is mandatory.
#
# *key:*
# The key of the account. This parameter is mandatory.
# You can generate a key value with this command:
#
#     ceph-authtool --gen-print-key
#
# *properties:*
# This parameter is an array of strings. Each string is
# a line in the keyring file. This parameter is mandatory.
#
# *global_options:*
# A hash of options in the global section in the $cluster.conf
# file. For example:
#
#   $global_options = {
#     'fsid'                      => 'e865b3d0-535a-4f18-9883-2793079d400b'
#     'osd_pool_default_min_size' => '1',
#     'osd_pool_default_pg_num'   => '256'
#   }
#
# This parameter is mandatory and the key 'fsid' is mandatory.
#
# *monitors:*
#
# A hash with this form:
#
#    { 'ceph-node1' => { 'id'            => '1',
#                        'address'       => '172.31.10.1',
#                        'initial'       => true,
#                      },
#      'ceph-node2' => { 'id'            => '2',
#                        'address'       => '172.31.10.2',
#                      },
#      'ceph-node3' => { 'id'            => '3',
#                        'address'       => '172.31.10.3',
#                      },
#    }
#
# The keys are the hostnames of the monitors. This parameter
# is mandatory and allows to create the ̀`[mon.<id>]` sections
# in the $cluster.conf file.
#
# *is_radosgw:*
# Boolean to tell if the client is a rados gateway.
# This parameter is optional and the default value
# is false.
#
# *common_rgw_dns_name:*
# If the client is a rados gateway, this parameter
# allows to define the entry "rgw dns name" in the
# `[client.<radosgw-id>]` sections. This parameter
# is optional and the default value is undef, and
# in this case the parameter has the same value as
# the `host` parameter.
#
# *admin_email:*
# If the host is a rados gateway, this parameter
# allows to define the email address in the vhost
# of the apache server.
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


