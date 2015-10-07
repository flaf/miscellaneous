function ceph::data {

  $clusters_conf      = undef # Must be defined by the user.
  $client_accounts    = {}
  $is_clusternode     = false
  $is_clientnode      = false
  $supported_distribs = ['trusty', 'jessie'];

  {
    ceph::clusters_conf           => $clusters_conf,
    ceph::client_accounts         => $client_accounts,
    ceph::is_clusternode          => $is_clusternode,
    ceph::is_clientnode           => $is_clientnode,
    ceph::supported_distributions => $supported_distribs,
  }

}


