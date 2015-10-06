function ceph::data {

  $clusters_conf      = undef # Must be defined by the user.
  $client_accounts    = {}
  $force_clusternode  = false
  $supported_distribs = ['trusty', 'jessie'];

  {
    ceph::clusters_conf           => $clusters_conf,
    ceph::client_accounts         => $client_accounts,
    ceph::force_clusternode       => $force_clusternode,
    ceph::supported_distributions => $supported_distribs,
  }

}


