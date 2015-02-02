# User defined type to manage the keyring of a specific ceph
# account in a ceph server node.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib and homemade_functions modules.
#
# == Parameters
#
# *cluster_name:*
# The name of the ceph cluster. The default value of this
# parameter is 'ceph'.
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
# *owner:*
# The owner of the keyring file. This parameter is optional
# and its default value is 'root'.
#
# *group:*
# The group of the keyring file. This parameter is optional
# and its default value is 'root'.
#
# *mode:*
# The Unix rights of the keyring file. This parameter is optional
# and its default value is '0600'.
#
# == Sample Usages
#
#  ::ceph::common::keyring { 'ceph.client.cinder':
#    cluster_name => ceph,
#    account      => 'cinder',
#    key          => 'AQDN3ZJUUHKwGRAAgqki1QW271BYliGfmwzREA==',
#    # In properties, we define the capabilities of the account.
#    # Below typical capabilities to create and mount rbd images
#    # in a specific pool ("volumes" in this example).
#    properties   => [
#      'caps mon = "allow r"',
#      'caps osd = "allow class-read object_prefix rbd_children, allow rwx pool=volumes"'
#    ],
#    owner        => 'cinder',
#    group        => 'cinder',
#  }
#
#
define ceph::common::keyring (
  $cluster_name = 'ceph',
  $account,
  $key,
  $properties,
  $owner        = 'root',
  $group        = 'root',
  $mode         = '0600',
) {

  validate_string(
    $cluster_name,
    $account,
    $key,
    $owner,
    $group,
    $mode,
  )

  validate_array($properties)

  # Maybe the node is client and server too. In this case,
  # the resource defined by the "cluster" class wins (if
  # called before this current user-defined).
  if !defined(File["/etc/ceph/${cluster_name}.client.${account}.keyring"]) {
    file { "/etc/ceph/${cluster_name}.client.${account}.keyring":
      ensure  => present,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      content => template('ceph/ceph.client.keyring.erb'),
    }
  }

}


