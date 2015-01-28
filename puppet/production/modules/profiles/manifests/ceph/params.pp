class profiles::ceph::params {

  $ceph_conf           = hiera_hash('ceph')
  $cluster_name        = $ceph_conf['cluster_name']
  $global_options      = $ceph_conf['global_options']
  $admin_key           = $ceph_conf['admin_key']
  $common_rgw_dns_name = $ceph_conf['common_rgw_dns_name'] # can be undefined.
  $monitors            = $ceph_conf['monitors']
  $keyrings            = $ceph_conf['keyrings']

  # Test if the data has been well retrieved.
  validate_non_empty_data(
    $cluster_name,
    $global_options,
    $admin_key,
    $monitors,
    $keyrings,
  )

  # Shared between cluster nodes and clients.
  $common = {
    'cluster_name'        => $cluster_name,
    'global_options'      => $global_options,
    'common_rgw_dns_name' => $common_rgw_dns_name,
    'monitors'            => $monitors,
  }

  $cluster_specific = {
    'admin_key' => $admin_key,
    'keyrings'  => $keyrings,
  }

  # Merge $common and $cluster_specific.
  $cluster = { "$cluster_name" =>  merge($common, $cluster_specific), }

}


