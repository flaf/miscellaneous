# TODO: write doc.
#       Put the management of ceph.conf in a specific file.
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


