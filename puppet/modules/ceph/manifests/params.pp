class ceph::params (
  String[1]                     $cluster_name,
  Optional[Ceph::ClusterConf]   $cluster_conf,
  Optional[Ceph::NodeType]      $nodetype,
  Optional[Array[String[1], 1]] $client_accounts,
  Array[String[1], 1]           $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

}


