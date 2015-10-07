define ceph::clusternode (
  String[1]                                         $cluster_name,
  Hash[String[1], Hash[String[1], Data, 1], 1]      $keyrings,
  Hash[String[1], Hash[String[1], String[1], 1], 1] $monitors,
  Hash[String[1], String[1], 1]                     $global_options,
) {

  require '::ceph::common::ceph_dir'
  require '::ceph::cluster::packages'
  require '::ceph::cluster::scripts'

  # Maybe the current node is a client too. In these cases,
  # maybe the configuration is already defined.
  if !defined(Class['::ceph::common::cephconf']) {
    class { '::ceph::common::cephconf':
      cluster_name   => $cluster_name,
      keyrings       => $keyrings,
      monitors       => $monitors,
      global_options => $global_options,
    }
  }

  $keyrings.each |$account, $params| {

    ::ceph::common::keyring { "cluster.${account}@${cluster_name}":
      cluster_name => $cluster_name,
      account      => $account,
      key          => $params['key'],
      properties   => $params['properties'],
      owner        => 'root',
      group        => 'root',
      mode         => '0600',
    }

  }

}


