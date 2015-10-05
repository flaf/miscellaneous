function ceph::data {

  $conf               = lookup('ceph_clusters', Hash[String[1], Data, 1], 'hash')
  $force_clusternode  = false
  $client_accounts    = {}
  $supported_distribs = ['trusty', 'jessie'];

  {
    ceph::force_clusternode       => $force_clusternode,
    ceph::clusters_conf           => $conf,
    ceph::client_accounts         => $client_accounts,
    ceph::supported_distributions => $supported_distribs,
  }

}


