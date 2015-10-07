class ceph::common::cephconf (
  String[1]                                         $cluster_name,
  Hash[String[1], Hash[String[1], Data, 1], 1]      $keyrings,
  Hash[String[1], Hash[String[1], String[1], 1], 1] $monitors,
  Hash[String[1], String[1], 1]                     $global_options,
) {

  # Configuration of the cluster file `$cluster.conf`.
  file { "/etc/ceph/${cluster_name}.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('ceph/ceph.conf.epp',
                   {
                     'cluster_name'   => $cluster_name,
                     'keyrings'       => $keyrings,
                     'monitors'       => $monitors,
                     'global_options' => $global_options,
                   }
                  ),
  }

}


