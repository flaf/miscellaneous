function ceph::check_client_accounts (
  Hash[String[1], Array[String[1]]]            $client_accounts,
  Hash[String[1], Hash[String[1], Data, 1], 1] $clusters_conf,
) {

  $client_accounts.each |$cluster_name, $accounts| {

    unless $clusters_conf.has_key($cluster_name) {
      @("END").regsubst('\n', ' ', 'G').fail
        ceph: the parameter `client_accounts` refers to the cluster
        `$cluster_name` which is not present in the `clusters_conf`
        parameter.
        |- END
    }

    $accounts.each |$account| {
      unless $clusters_conf['keyrings'].has_key($account) {
        @("END").regsubst('\n', ' ', 'G').fail
          ceph: the parameter `client_accounts` refers to the account
          `$account` in the cluster `$cluster_name` but this account
          does not exist in the cluster `$cluster_name` defined in the
          parameter `clusters_conf`.
          |- END
      }
    }

  }

  # All is OK.
  true

}


