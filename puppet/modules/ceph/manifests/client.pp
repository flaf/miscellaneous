define ceph::client (
  String[1]                                         $cluster_name,
  Hash[String[1], Hash[String[1], Data, 1], 1]      $keyrings,
  Hash[String[1], Hash[String[1], Data, 1], 1]      $client_keyrings,
  Hash[String[1], Hash[String[1], String[1], 1], 1] $monitors,
  Hash[String[1], String[1], 1]                     $global_options,
) {

  require '::ceph::common::ceph_dir'
  require '::ceph::client::packages'

  # Maybe the current node is a server too. In these cases,
  # maybe the configuration is already defined.
  if !defined(Class['::ceph::common::cephconf']) {
    class { '::ceph::common::cephconf':
      cluster_name   => $cluster_name,
      keyrings       => $keyrings,
      monitors       => $monitors,
      global_options => $global_options,
    }
  }

  $client_keyrings.each |$account, $params| {

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

  $is_radosgw = !$client_keyrings.keys.filter |$k| { $k =~ /^radosgw/ }.empty

  if $is_radosgw {

    ::ceph::radosgw { "${cluster_name}-${account}":
      cluster_name => $cluster_name,
      account      => $account,
    }

  }

}


