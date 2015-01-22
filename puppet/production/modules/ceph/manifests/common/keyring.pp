# User defined type to manage the keyring of a specific ceph account
# in a ceph server node.
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
# *magic_tag:*
# The keyring is exported in order to be imported by ceph
# clients. The keyring is tagged with these strings:
# 'ceph-keyring', 'account' and the magic_tag (after
# expansion). This parameter is optional and the default
# value is "$cluster_name". A possible value for this
# parameter is '@datacenter-ceph' where @datacenter will be
# expanded (if the variable is defined).
#
# Note: if the radosgw_host parameter is set (see below)
#       this parameter is used in tags instead of 'account'.
#
# *exported:*
# A boolean to tell if the keyring must be exported.
# This parameter is optional and the default value is
# false (not exported). In fact, if "exported" ==  false,
# the resource will never be created directly but from an
# import of a exported resource.
#
# *radosgw_host:*
# If the keyring is intended for a radosgw server, you must
# set this parameter (a string) to the hostname of the
# corresponding radosgw server. This parameter is optional
# and the default value is undef (ie the keyring is not
# intended for a radosgw).
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
#
# *properties:*
# This parameter is an array of strings. Each string is
# a line in the keyring file. This parameter is mandatory.
#
# == Sample Usages
#
#  ::ceph::common::keyring { 'ceph.client.cinder':
#    cluster_name => ceph,
#    magic_tag    => '@datacenter-ceph',
#    exported     => true,
#    account      => 'cinder',
#    key          => 'AQDN3ZJUUHKwGRAAgqki1QW271BYliGfmwzREA==',
#    # In properties, we define the capabilities of the account.
#    # Below typical capabilities to create and mount rbd images
#    # in a specific pool ("volumes" in this example).
#    properties   => [
#      'caps mon = "allow r"',
#      'caps osd = "allow class-read object_prefix rbd_children, allow rwx pool=volumes"'
#    ],
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


