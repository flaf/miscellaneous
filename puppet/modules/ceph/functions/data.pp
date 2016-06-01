function ceph::data {

  $supported_distribs = ['trusty', 'jessie'];

  {
    ceph::params::cluster_name            => 'ceph',
    ceph::params::cluster_conf            => undef,
    ceph::params::nodetype                => undef,
    ceph::params::client_accounts         => undef,
    ceph::params::supported_distributions => $supported_distribs,
  }

}


