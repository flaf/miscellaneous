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
  $radosgw_host = undef,
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

  if $radosgw_host != undef {
    validate_string($radosgw_host)
  }

  validate_array($properties)

  if $exported {

    if $magic_tag == undef {
      fail("ceph::cluster::keyring ${title}, `exported` parameter is set to \
true but no magic_tag is defined for this resource.")
    }

  }

  # "@xxx" variables are allowed in $magic_tag string.
  $tag_expanded = inline_template(str2erb($magic_tag))

  if $radosgw_host == undef {
    # This is a classic keyring, we use the account name for the tag
    # of the exported file below.
    $tag_keyring = $account
  } else {
    # This is a keyring for radosgw, we use the hostname of the
    # radosgw for the tag.
    $tag_keyring = $radosgw_host
  }

  if $exported {

    @@file { "ceph-keyring-${cluster_name}-${account}-${tag_expanded}":
      path    => "/etc/ceph/${cluster_name}.client.${account}.keyring",
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => template('ceph/ceph.client.keyring.erb'),
      tag     => [ 'ceph-keyring', $tag_expanded, $tag_keyring ],
    }

  } else {

    # If the host is server and client ceph, we want to retrieve
    # the file just one time.
    if !defined(File["ceph-keyring-${cluster_name}-${account}-${tag_expanded}"]) {
      File <<|     tag == 'ceph-keyring'
               and tag == 'ceph::cluster::keyring'
               and tag == $tag_expanded
               and tag == $tag_keyring |>> {}
    }

  }

}


