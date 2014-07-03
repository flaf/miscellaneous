class apache_poller {

  $poller_packages = [
    'libnet-snmp-perl',
  ]

  package { 'poller_packages':
    ensure => latest,
    name   => $poller_packages,
  }

  file { '/usr/lib/cgi-bin/it-works.pl':
    owner  => 'root',
    group  => 'root',
    mode   => 755,
    source => 'puppet:///modules/apache_poller/it-works.pl',
  }

}


