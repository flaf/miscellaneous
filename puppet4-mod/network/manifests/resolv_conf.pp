class network::resolv_conf (
  String[1]           $domain,
  Array[String[1], 1] $search,
  Array[String[1], 1] $nameservers,
  Integer[1]          $timeout,
) {

  file { '/etc/resolv.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('network/resolv.conf.epp',
                   { 'domain'      => $domain,
                     'search'      => $search,
                     'nameservers' => $nameservers,
                     'timeout'     => $timeout,
                   }
                  ),
  }

}


