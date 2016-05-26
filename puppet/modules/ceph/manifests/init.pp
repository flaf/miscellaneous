class ceph {

  include '::ceph::params'
  $clusters_conf   = $::ceph::params::clusters_conf
  $client_accounts = $::ceph::params::client_accounts
  $is_clusternode  = $::ceph::params::is_clusternode
  $is_clientnode   = $::ceph::params::is_clientnode

  ensure_packages( [ 'ceph' ], { ensure => present, } )

  file { '/etc/ceph':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,
    require => Package['ceph'],
  }

  if $is_clientnode {

    $client_accounts.each |$cluster_name, $accounts_array| {

      if $is_clusternode {
        $before = ::Ceph::Clusternode[$cluster_name]
      } else {
        $before = undef
      }

      $all_keyrings    = $clusters_conf[$cluster_name]['keyrings']
      $client_keyrings = $all_keyrings.filter |$account, $properties| {
                           $account in $accounts_array
                         }

      ::ceph::client { $cluster_name:
        cluster_name    => $cluster_name,
        keyrings        => $all_keyrings,
        client_keyrings => $client_keyrings,
        monitors        => $clusters_conf[$cluster_name]['monitors'],
        global_options  => $clusters_conf[$cluster_name]['global_options'],
        is_clusternode  => $is_clusternode,
        is_clientnode   => $is_clientnode,
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
        is_clusternode => $is_clusternode,
        is_clientnode  => $is_clientnode,
      }

    }

  } # End if clusternode.

}


