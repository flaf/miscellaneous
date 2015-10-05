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
# This parameter is optional and the default value
# is the title of the current resource.
#
# *secret_file:*
# This parameter is a boolean and its default value is false.
# If set to true, in addition to create the keyring file
# /etc/ceph/$cluster.client.$account.keyring, the file
# /etc/ceph/$cluster.client.$account.secret will be created
# with just the key of the account. It can be useful with
# cephfs where the command:
#
#     mount -t mon1,mon2,mon3:6789:/ /mnt/ -o name=<account>,secretfile=<path>
#
# needs to the "secretfile" option and the secretfile must just
# contain the key of the account (a keyring file will not work).
#
# *key:*
# The key of the account. This parameter is mandatory.
# You can generate a key value with this command:
#
#     apt-get install ceph-common && ceph-authtool --gen-print-key
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
# is mandatory and allows to create the `[mon.<id>]` sections
# in the $cluster.conf file.
#
# *is_radosgw:*
# Boolean to tell if the client is a rados gateway.
# This parameter is optional and the default value
# is false.
#
# *rgw_dns_name:*
# If the client is a rados gateway, this parameter
# allows to define the entry "rgw dns name" in the
# `[client.<radosgw-id>]` sections. This parameter
# is optional and the default value is undef, and
# in this case the parameter is not defined.
#
# == Sample Usages
#
#  $monitors = ... # the same as above.
#
#  ::ceph::client { 'ceph-radosgw.gw1':
#    cluster_name        => 'ceph',
#    account             => 'radosgw.gw1',
#    key                 => 'AQDN3ZJUUHKwGRAAgqki1QW271BYliGfmwzREA==',
#    properties          => [
#      'caps mon = "allow rwx"',
#      'caps osd = "allow rwx"',
#    ],
#    global_options      => {
#      'fsid' => 'e865b3d0-535a-4f18-9883-2793079d400b'
#    },
#    monitors            => $monitors,
#    is_radosgw          => true,
#    rgw_dns_name        => 'radosgw',
#  }
#
define ceph::client (
  String[1]                                         $cluster_name,
  Hash[String[1], Hash[String[1], Data, 1], 1]      $keyrings,
  Hash[String[1], Hash[String[1], String[1], 1], 1] $monitors,
  Hash[String[1], String[1], 1]                     $global_options,
) {

  require '::ceph::client::packages'
  require '::ceph::common::ceph_dir'

  # Maybe the current node is server too. In these cases,
  # the file is already defined.
  if !defined(File["/etc/ceph/${cluster_name}.conf"]) {
    # Configuration file of the cluster.
    file { "/etc/ceph/${cluster_name}.conf":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('ceph/ceph.conf.epp',
                     {
                       'cluster_name'   => $cluster_name,
                       'global_options' => $global_options,
                       'monitors'       => $monitors,
                       'keyrings'       => $keyrings,
                     }
                    ),
    }
  }

  $keyrings.each |$account, $params| {

    if $params.has_key('owner') {
      $owner = $params['owner']
    } else {
      $owner = 'root'
    }

    if $params.has_key('group') {
      $group = $params['group']
    } else {
      $group = 'root'
    }

    if $params.has_key('mode') {
      $mode = $params['mode']
    } else {
      $mode = '0600'
    }

    ::ceph::common::keyring { "client.${account}@${cluster_name}":
      cluster_name => $cluster_name,
      account      => $account,
      key          => $params['key'],
      properties   => $params['properties'],
      owner        => $owner,
      group        => $group,
      mode         => $mode,
    }

    $key = $params['key']

    file { "/etc/ceph/${cluster_name}.client.${account}.secret":
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      content => "${key}\n",
    }

  }

  $is_radosgw = !$keyrings.keys.filter |$k| { $k =~ /^radosgw/ }.empty

  if $is_radosgw {

    ::ceph::radosgw { "${cluster_name}-${account}":
      cluster_name => $cluster_name,
      account      => $account,
    }

  }

}


