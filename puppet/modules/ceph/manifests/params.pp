class ceph::params (
  Hash[String[1], Ceph::ClusterConf, 1] $clusters_conf,
  Hash[String[1], Array[String[1]]]     $client_accounts,
  Boolean                               $is_clusternode,
  Boolean                               $is_clientnode,
  Array[String[1], 1]                   $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

}


