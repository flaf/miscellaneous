class profiles::ceph::params {

  $ceph_conf    = hiera_hash('ceph')
  $cluster_name = $ceph_conf['cluster_name']
  $cluster_tag  = $ceph_conf['cluster_tag']

  # Test if the data has been well retrieved.
  validate_non_empty_data(
    $cluster_name,
    $cluster_tag,
  )

}


