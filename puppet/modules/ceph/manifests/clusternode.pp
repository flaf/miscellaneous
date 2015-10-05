define ceph::clusternode
(
  String[1]                                         $cluster_name,
  Hash[String[1], Hash[String[1], Data, 1], 1]      $keyrings,
  Hash[String[1], Hash[String[1], String[1], 1], 1] $monitors,
  Hash[String[1], String[1], 1]                     $global_options,
) {

  require '::ceph::common::ceph_dir'
  require '::ceph::cluster::packages'
  require '::ceph::cluster::scripts'

  # Configuration file of the cluster.
  file { "/etc/ceph/${cluster_name}.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('ceph/ceph.conf.epp',
                   {
                     'cluster_name'   => $cluster_name,
                     'global_options' => $global_options,
                     'monitors'       => $monitors,
                     'keyrings'       => $keyrings,
                   }
                  ),
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


