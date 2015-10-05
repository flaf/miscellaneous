define ceph::client (
  String[1]                                         $cluster_name,
  Hash[String[1], Hash[String[1], Data, 1], 1]      $keyrings,
  Hash[String[1], Hash[String[1], String[1], 1], 1] $monitors,
  Hash[String[1], String[1], 1]                     $global_options,
) {

  require '::ceph::client::packages'
  require '::ceph::common::ceph_dir'

  # Maybe the current node is server too. In these cases,
  # the file is already defined.
  if !defined(File["/etc/ceph/${cluster_name}.conf"]) {
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
  }

  $keyrings.each |$account, $params| {

    if $params.has_key('owner') {
      $owner = $params['owner']
    } else {
      $owner = 'root'
    }

    if $params.has_key('group') {
      $group = $params['group']
    } else {
      $group = 'root'
    }

    if $params.has_key('mode') {
      $mode = $params['mode']
    } else {
      $mode = '0600'
    }

    ::ceph::common::keyring { "client.${account}@${cluster_name}":
      cluster_name => $cluster_name,
      account      => $account,
      key          => $params['key'],
      properties   => $params['properties'],
      owner        => $owner,
      group        => $group,
      mode         => $mode,
    }

    $key = $params['key']

    file { "/etc/ceph/${cluster_name}.client.${account}.secret":
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      content => "${key}\n",
    }

  }

  $is_radosgw = !$keyrings.keys.filter |$k| { $k =~ /^radosgw/ }.empty

  if $is_radosgw {

    ::ceph::radosgw { "${cluster_name}-${account}":
      cluster_name => $cluster_name,
      account      => $account,
    }

  }

}


