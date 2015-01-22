class profiles::ceph::params {

  $ceph_conf               = hiera_hash('ceph')
  $cluster_name            = $ceph_conf['cluster_name']
  $osd_journal_size        = $ceph_conf['osd_journal_size']
  $osd_pool_default_size   = $ceph_conf['osd_pool_default_size']
  $osd_pool_default_pg_num = $ceph_conf['osd_pool_default_pg_num']
  $cluster_network         = $ceph_conf['cluster_network']
  $public_network          = $ceph_conf['public_network']
  $fsid                    = $ceph_conf['fsid']
  $monitors                = $ceph_conf['monitors']
  $keyrings                = $ceph_conf['keyrings']
  $admin_key               = $ceph_conf['admin_key']

  # Test if the data has been well retrieved.
  validate_non_empty_data(
    $cluster_name,
    $osd_journal_size,
    $osd_pool_default_size,
    $osd_pool_default_pg_num,
    $cluster_network,
    $public_network,
    $fsid,
    $monitors,
    $keyrings,
    $admin_key,
  )

  # Shared between cluster nodes and clients.
  $common = {
    'cluster_name'            => $cluster_name,
    'osd_journal_size'        => $osd_journal_size,
    'osd_pool_default_size'   => $osd_pool_default_size,
    'osd_pool_default_pg_num' => $osd_pool_default_pg_num,
    'cluster_network'         => $cluster_network,
    'public_network'          => $public_network,
    'fsid'                    => $fsid,
    'monitors'                => $monitors,
  }

  $cluster_specific = {
    'keyrings'  => $keyrings,
    'admin_key' => $admin_key,
  }

  # Merge $common and $cluster_specific.
  $cluster = { "$cluster_name" =>  merge($common, $cluster_specific), }

}


