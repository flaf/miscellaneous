function ceph::data {

  $conf               = undef # Must be defined by the user.
  $force_clusternode  = false
  $client_accounts    = {}
  $supported_distribs = ['trusty', 'jessie'];

  {
    ceph::clusters_conf           => $conf,
    ceph::force_clusternode       => $force_clusternode,
    ceph::client_accounts         => $client_accounts,
    ceph::supported_distributions => $supported_distribs,
  }

}


