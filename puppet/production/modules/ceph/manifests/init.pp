class ceph (
  $cluster_name = 'ceph'
) {

  validate_string($cluster_name)

  require '::ceph::packages'

}


