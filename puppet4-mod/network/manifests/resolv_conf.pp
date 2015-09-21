class network::resolv_conf (
  String[1]           $domain,
  Array[String[1], 1] $search,
  Array[String[1], 1] $nameservers,
  Integer[1]          $timeout,
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  # With "ensure => file" is the file is a symlink to
  # "../run/resolvconf/resolv.conf", the symlink will
  # be removed and replaced by a regular file. So,
  # resolvconf mechanism will be disabled.
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


