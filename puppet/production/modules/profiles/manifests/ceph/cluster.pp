class profiles::ceph::cluster {

  $ceph_conf               = hiera_hash('ceph')
  $cluster_name            = $ceph_conf['cluster_name']
  $fsid                    = $ceph_conf['fsid']
  $monitors                = $ceph_conf['monitors']
  $monitors_key            = $ceph_conf['monitors_key']
  $monitor_init            = $ceph_conf['monitor_init']
  $admin_key               = $ceph_conf['admin_key']
  $osd_journal_size        = $ceph_conf['osd_journal_size']
  $osd_pool_default_size   = $ceph_conf['osd_pool_default_size']
  $osd_pool_default_pg_num = $ceph_conf['osd_pool_default_pg_num']

  # Test if the data has been well retrieved.
  validate_non_empty_data(
    $cluster_name,
    $fsid,
    $monitors,
    $monitor_init,
    $monitors_key,
    $admin_key,
    $osd_journal_size,
    $osd_pool_default_size,
    $osd_pool_default_pg_num,
  )

  class { '::ceph':
    cluster_name            => $cluster_name,
    fsid                    => $fsid,
    monitors                => $monitors,
    monitors_key            => $monitors_key,
    monitor_init            => $monitor_init,
    admin_key               => $admin_key,
    osd_journal_size        => $osd_journal_size,
    osd_pool_default_size   => $osd_pool_default_size,
    osd_pool_default_pg_num => $osd_pool_default_pg_num,
  }

}


