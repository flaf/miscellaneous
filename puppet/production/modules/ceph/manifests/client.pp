# TODO: write doc.
#
define ceph::client (
  $cluster_name = 'ceph',
  $magic_tag    = $cluster_name,
  $account,
) {

  require '::ceph::client::packages'

  $tag_expanded = inline_template(str2erb($magic_tag))

  # Retrieve the conf of the Ceph cluster.
  File <<| tag == 'ceph-conf' and tag == $tag_expanded |>> {}

  # Retrieve the keyring of the Ceph account.
  File <<| tag == 'ceph-keyring' and tag == $tag_expanded and tag == $account |>> {}

}


