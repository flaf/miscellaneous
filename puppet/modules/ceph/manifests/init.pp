class ceph {

  $params = '::ceph::params'
  include $params
  $cluster_name    = ::homemade::getvar("${params}::cluster_name", $title)
  $cluster_conf    = ::homemade::getvar("${params}::cluster_conf", $title)
  $nodetype        = ::homemade::getvar("${params}::nodetype", $title)
  # the variable $client_accounts can be undef.
  $client_accounts = getvar("${params}::client_accounts")

  ::ceph::node { $cluster_name:
    cluster_conf    => $cluster_conf,
    nodetype        => $nodetype,
    client_accounts => $client_accounts,
  }

}


