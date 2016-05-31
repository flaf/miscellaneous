define ceph::clusternode (
  String[1]                     $cluster_name = $title,
  Ceph::ClusterConf             $cluster_conf,
  Ceph::NodeType                $nodetype,
  Optional[Array[String[1], 1]] $client_accounts = undef,
) {

  # Check if $nodetype and $client_accounts are consistent.
  case [$nodetype == 'client', $client_accounts] {
    [true,  Undef] {
      @("END"/L).fail
        ${title}: the type of the node is `client` but the parameter \
        `client_accounts` is undef which is forbidden in this case.
        |- END
    }
    [false, NotUndef] {
      @("END"/L).fail
        ${title}: the type of the node is not `client` but the parameter \
        `client_accounts` is not undef which is forbidden in this case.
        |- END
    }
  }

  require '::ceph::basis'

  # Configuration of the cluster file `$cluster.conf`.
  file { "/etc/ceph/${cluster_name}.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('ceph/ceph.conf.epp',
                   {
                     'cluster_name' => $cluster_name,
                     'cluster_conf' => $cluster_conf,
                     'nodetype' => $nodetype,
                   }
                  ),
  }

  case $nodetype {

    'clusternode': {

      include '::ceph::clusterscripts'

      $packages = [
        'ceph',
        'ceph-mds',
        'ceph-fuse', # To be able (sometime) to mount the cephfs in a
                     # cluster node.
        'xfsprogs',  # For xfs filesystem.
        'procps',    # Used in the ceph_* scripts.
        'jq',        # To parse json, could be useful. For instance:
                     # ceph cmd --format json | jq '.'
        'bc',        # used in the script ceph-osd-remove.
      ]

      ensure_packages($packages, { ensure => present, })

    }

    'clientnode': {

    }

    'radosgw': {

    }

  }



  # Maybe the current node is a client too. In these cases,
  # maybe the configuration is already defined.
  if !defined(Class['::ceph::common::cephconf']) {
    class { '::ceph::common::cephconf':
      cluster_name   => $cluster_name,
      keyrings       => $keyrings,
      monitors       => $monitors,
      global_options => $global_options,
      is_clusternode => $is_clusternode,
      is_clientnode  => $is_clientnode,
    }
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


