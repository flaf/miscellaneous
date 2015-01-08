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
# *exported:*
# A boolean to tell if the keyring must be exported.
# This parameter is optional and the default value is
# false (not exported).
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
#  ::ceph::cluster::keyring { 'ceph.client.cinder':
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
define ceph::cluster::keyring (
  $cluster_name = 'ceph',
  $magic_tag    = $cluster_name,
  $exported     = false,
  $account,
  $key,
  $properties,
) {

  validate_bool($exported)

  validate_string(
    $cluster_name,
    $magic_tag,
    $account,
    $key,
  )

  validate_array($properties)

  if $exported {

    if $magic_tag == undef {
      fail("ceph::cluster::keyring ${title}, `exported` parameter is set to \
true but no magic_tag is defined for this resource.")
    }

    # "@xxx" variables are allowed in $magic_tag string.
    $tag_expanded = inline_template(str2erb($magic_tag))

  }

  if $exported {

    @@file { "ceph-keyring-${cluster_name}-${account}-${::fqdn}":
      path    => "/etc/ceph/${cluster_name}.client.${account}.keyring",
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => template('ceph/ceph.client.keyring.erb'),
      tag     => [ 'ceph-keyring', $tag_expanded, $account ],
    }

  } else {

    file { "/etc/ceph/${cluster_name}.client.${account}.keyring":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => template('ceph/ceph.client.keyring.erb'),
    }

  }

}


