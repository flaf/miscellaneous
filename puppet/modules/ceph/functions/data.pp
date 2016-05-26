function ceph::data {

  $clusters_conf      = undef # Must be defined by the user.
  $client_accounts    = {}
  $is_clusternode     = false
  $is_clientnode      = false
  $supported_distribs = ['trusty', 'jessie'];

  {
    ceph::params::clusters_conf           => $clusters_conf,
    ceph::params::client_accounts         => $client_accounts,
    ceph::params::is_clusternode          => $is_clusternode,
    ceph::params::is_clientnode           => $is_clientnode,
    ceph::params::supported_distributions => $supported_distribs,
  }

}


