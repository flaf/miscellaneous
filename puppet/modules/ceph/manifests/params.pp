class ceph::params (
  Hash[String[1], Ceph::ClusterConf, 1] $clusters_conf,
  Hash[String[1], Array[String[1]]]     $client_accounts,
  Boolean                               $is_clusternode,
  Boolean                               $is_clientnode,
  Array[String[1], 1]                   $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  # check the parameters.
  ::ceph::check_client_accounts($client_accounts, $clusters_conf)

  if $is_clusternode == false and $is_clientnode == false {
    @("END"/L$).fail
      ${title}: the boolean parameters `is_clusternode` and `is_clientnode` \
      are both false but at least one of these two parameters must be set \
      to true.
      |- END
  }

}


