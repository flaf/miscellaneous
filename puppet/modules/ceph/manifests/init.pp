class ceph {

  include '::ceph::params'

  [
    $cluster_name,
    $cluster_conf,
    $nodetype,
    $client_accounts, # the variable $client_accounts can be undef.
    $supported_distributions,
  ] = Class['::ceph::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  ::homemade::fail_if_undef($cluster_conf, 'ceph::params::cluster_conf', $title)
  ::homemade::fail_if_undef($nodetype,     'ceph::params::nodetype',     $title)

  ::ceph::node { $cluster_name:
    cluster_conf    => $cluster_conf,
    nodetype        => $nodetype,
    client_accounts => $client_accounts,
  }

}


