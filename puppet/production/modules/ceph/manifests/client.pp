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
# value.
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
  $cluster_name = 'ceph',
  $magic_tag    = $cluster_name,
  $owner        = 'root',
  $group        = 'root',
  $mode         = '0600',
  $account,
) {

  require '::ceph::client::packages'
  require '::ceph::common::ceph_dir'

  validate_string(
    $cluster_name,
    $magic_tag,
    $owner,
    $group,
    $mode,
    $account,
  )

  $tag_expanded = inline_template(str2erb($magic_tag))

  # Retrieve the conf of the Ceph cluster.
  File <<|     tag == 'ceph-conf'
           and tag == $tag_expanded |>> {}

  # Retrieve the keyring of the Ceph account.
  File <<|     tag == 'ceph-keyring'
           and tag == 'ceph::cluster::keyring'
           and tag == $tag_expanded
           and tag == $account |>> {
    owner => $owner,
    group => $group,
    mode  => $mode,
  }

}


