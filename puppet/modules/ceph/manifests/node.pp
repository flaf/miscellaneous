define ceph::node (
  String[1]                     $cluster_name = $title,
  Ceph::ClusterConf             $cluster_conf,
  Ceph::NodeType                $nodetype,
  Optional[Array[String[1], 1]] $client_accounts = undef,
) {

  # Check if $nodetype and $client_accounts are consistent.
  case [$nodetype == 'clientnode', $client_accounts] {
    [true,  Undef]: {
      @("END"/L).fail
        ${title}: the type of the node is `clientnode` but the parameter \
        `client_accounts` is undef which is forbidden in this case.
        |- END
    }
    [true, NotUndef]: {
      $client_accounts.each |$a_account| {
        unless $a_account in $cluster_conf['keyrings'] {
          @("END"/L).fail
            ${title}: the type of the node is `clientnode` but its ceph \
            account `${a_account}` is not present in the keyrings of \
            the `cluster_conf` parameter.
            |- END
        }
      }
    }
    [false, NotUndef]: {
      @("END"/L).fail
        ${title}: the type of the node is not `clientnode` but the parameter \
        `client_accounts` is provided (ie not undef) which is forbidden in \
        this case (if the node is not a client node, the `client_accounts` \
        parameter must be undef).
        |- END
    }
  }

  # Check parameters when $nodetype == 'radosgw'.
  case [$nodetype == 'radosgw', 'rgw_instances' in $cluster_conf] {
    [true, false]: {
      @("END"/L).fail
        ${title}: the type of the node is `radosgw` but the parameter \
        `cluster_conf` has no `rgw_instances` key which is mandatory \
        in this case.
        |- END
    }
    [true, true]: {
      $own_rgw_instances = $cluster_conf['rgw_instances'].filter |$name, $params| {
        $::hostname in $params['hosts']
      }
      if $own_rgw_instances.empty {
        @("END"/L).fail
          ${title}: the type of the node is `radosgw` but there is no \
          rados gateway instance which is set for the current host \
          (ie ${::hostname}) in the `cluster_conf` parameter.
          |- END
      }
      $own_rgw_instances.each |$instance_name, $params| {
        unless $params['keyring'] in $cluster_conf['keyrings'] {
          @("END"/L).fail
            ${title}: the type of the node is `radosgw` but the keyring \
            `${params['keyring']}` is not present among the keyring files \
            of the `cluster_conf` parameter.
            |- END
        }
      }
    }
  }

  require '::ceph::basis'

  # Configuration of the cluster file `$cluster.conf`.
  file { "/etc/ceph/${cluster_name}.conf":
    ensure  => present,
    owner   => 'ceph',
    group   => 'ceph',
    mode    => '0640',
    content => epp('ceph/ceph.conf.epp',
                   {
                     'cluster_name' => $cluster_name,
                     'cluster_conf' => $cluster_conf,
                     'nodetype'     => $nodetype,
                   }
                  ),
  }

  # The keyrings present in the host.
  $keyrings = case $nodetype {

    'clusternode': {
      $cluster_conf['keyrings']
    }

    'clientnode': {
      $cluster_conf['keyrings'].filter |$a_keyring, $params| {
        $a_keyring in $client_accounts
      }
    }

    'radosgw': {
      $keyrings_array = $cluster_conf['rgw_instances'].reduce([]) |$memo, $entry| {
        [ $instance_name, $params ] = $entry
        case $::hostname in $params['hosts'] {
          true:  { $memo + [ $params['keyring'] ] }
          false: { $memo                          }
        }
      }
      $cluster_conf['keyrings'].filter |$a_keyring, $params| {
        $a_keyring in $keyrings_array
      }
    }

  }

  $keyrings.each |$account, $params| {

    [$owner, $group, $mode] = case $nodetype {
      'clientnode': {
        [ $params.dig('owner').lest || { 'ceph' },
          $params.dig('group').lest || { 'ceph' },
          $params.dig('mode').lest  || { '0600' },
        ]
      }
      default: { ['ceph', 'ceph', '0600'] }
    }

    file { "/etc/ceph/${cluster_name}.client.${account}.keyring":
      ensure  => present,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      content => epp('ceph/ceph.client.keyring.epp',
                     {
                      'account'      => $account,
                      'key'          => $params['key'],
                      'capabilities' => $params['capabilities'],
                     }
                    ),
    }

    # For a clientnode node, we add the .secret keyrings (with
    # only the key).
    if $nodetype == 'clientnode' {
      $key = $params['key']
      file { "/etc/ceph/${cluster_name}.client.${account}.secret":
        owner   => $owner,
        group   => $group,
        mode    => $mode,
        content => "${key}\n",
      }
    }

  }

  case $nodetype {

    'clusternode': {

      include '::ceph::clusterscripts'

      $packages = [
        'ceph',
        'ceph-mds',
        'ceph-fuse', # To be able to mount the cephfs in a cluster node.
        'xfsprogs',  # For xfs filesystem.
        'procps',    # Used in the ceph_* scripts.
        'jq',        # To parse json, could be useful.
        'bc',        # Used in the script ceph-osd-remove.
      ]
      ensure_packages($packages, { ensure => present, })

    }

    'clientnode': {

      # Seems to be surer to install the "ceph" package in a
      # client because when you run a "ceph xxx" command you
      # have an error about the unfound "ceph_argparse"
      # module which is in the "ceph" package (but the
      # "ceph" command is in the "ceph-common" package).. In
      # fact, it's probably a temporary bug:
      # https://github.com/ceph/ceph/pull/4517
      $packages = [
        'ceph',
        'ceph-common',    # To use Rados block devices.
        'ceph-fs-common', # To mount cephfs via the kernel.
        'ceph-fuse',      # To mount cephfs via Fuse.
      ]
      ensure_packages($packages, { ensure => present, })

    }

    'radosgw': {

      $packages = [ 'ceph', 'radosgw' ]
      ensure_packages($packages, { ensure => present, })

      $rgw_instances = $cluster_conf['rgw_instances'].filter |$i, $params| {
        $::hostname in $params['hosts']
      }

      $rgw_instances.each |$instance_name, $params| {
        ::ceph::radosgw { "${cluster_name}-${instance_name}":
          cluster_name  => $cluster_name,
          instance_name => $instance_name,
          require       => [Package['ceph'], Package['radosgw']],
        }
      }

    }

  }

}


