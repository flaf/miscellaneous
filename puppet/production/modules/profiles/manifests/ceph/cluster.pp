class profiles::ceph::cluster {

  require '::profiles::ceph::params'

  $ceph_conf               = $::profiles::ceph::params::ceph_conf
  $cluster_name            = $::profiles::ceph::params::cluster_name
  $cluster_tag             = $::profiles::ceph::params::cluster_tag
  $fsid                    = $ceph_conf['fsid']
  $monitors                = $ceph_conf['monitors']
  $admin_key               = $ceph_conf['admin_key']
  $osd_journal_size        = $ceph_conf['osd_journal_size']
  $osd_pool_default_size   = $ceph_conf['osd_pool_default_size']
  $osd_pool_default_pg_num = $ceph_conf['osd_pool_default_pg_num']
  $cluster_network         = $ceph_conf['cluster_network']
  $public_network          = $ceph_conf['public_network']
  $keyrings                = $ceph_conf['keyrings']

  # Test if the data has been well retrieved.
  validate_non_empty_data(
    $fsid,
    $monitors,
    $admin_key,
    $osd_journal_size,
    $osd_pool_default_size,
    $osd_pool_default_pg_num,
    $keyrings,
    $cluster_network,
    $public_network,
  )

  ::ceph::cluster { $cluster_name:
    cluster_name            => $cluster_name,
    magic_tag               => $cluster_tag,
    fsid                    => $fsid,
    monitors                => $monitors,
    admin_key               => $admin_key,
    osd_journal_size        => $osd_journal_size,
    osd_pool_default_size   => $osd_pool_default_size,
    osd_pool_default_pg_num => $osd_pool_default_pg_num,
    cluster_network         => $cluster_network,
    public_network          => $public_network,
    keyrings                => $keyrings,
  }

}


