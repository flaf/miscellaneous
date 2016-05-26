define ceph::node (
  String[1]                             $cluster_name,
  Hash[String[1], Ceph::ClusterConf, 1] $clusters_conf,
  Ceph::NodeType                        $type,
  Hash[String[1], Array[String[1]]]     $client_accounts = {},
  Boolean                               $is_clusternode,
  Boolean                               $is_clientnode,
  Array[String[1], 1]                   $supported_distributions,
) {

  if !$client_accounts
  ::ceph::check_client_accounts($client_accounts, $clusters_conf)

  require '::ceph::basis'

}


