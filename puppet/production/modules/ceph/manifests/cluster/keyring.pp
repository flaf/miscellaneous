# User defined type to manage the keyring of a specific ceph account
# in a ceph server node.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib and homemade_function.
#
# == Parameters
#
# *cluster_name:*
# The name of the ceph cluster. The default value of this
# parameter is 'ceph'.
#
# *magic_tag:*
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


