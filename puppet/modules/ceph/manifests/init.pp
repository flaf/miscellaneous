class ceph (
  Hash[String[1], Hash[String[1], Data, 1], 1] $clusters_conf,
  Hash[String[1], Array[String[1]]]            $client_accounts,
  Boolean                                      $is_clusternode,
  Boolean                                      $is_clientnode,
  Array[String[1], 1]                          $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  # check the parameters.
  ::ceph::check_clusters_conf($clusters_conf)
  ::ceph::check_client_accounts($client_accounts, $clusters_conf)

  if $is_clientnode {

    $client_accounts.each |$cluster_name, $accounts_array| {

      if $is_clusternode {
        $before = ::Ceph::Clusternode[$cluster_name]
      } else {
        $before = undef
      }

      $all_keyrings    = $clusters_conf[$cluster_name]['keyrings']

      # Filter keyrings only from $client_accounts.
      $client_keyrings = $all_keyrings.filter |$account, $properties| {
        $accounts_array.member($account)
      }

      ::ceph::client { $cluster_name:
        cluster_name    => $cluster_name,
        keyrings        => $all_keyrings,
        client_keyrings => $client_keyrings,
        monitors        => $clusters_conf[$cluster_name]['monitors'],
        global_options  => $clusters_conf[$cluster_name]['global_options'],
        before          => $before,
      }

    }

  } # End if clientnode.

  if $is_clusternode {

    $clusters_conf.each |$cluster_name, $conf| {

      ::ceph::clusternode { $cluster_name:
        cluster_name   => $cluster_name,
        keyrings       => $conf['keyrings'],
        monitors       => $conf['monitors'],
        global_options => $conf['global_options'],
      }

    }

  } # End if clusternode.

}


