class apache_poller {

  $poller_packages = [
    'libnet-snmp-perl',
    'curl',
  ]

  package { 'poller_packages':
    ensure => present,
    name   => $poller_packages,
  }

  file { '/usr/lib/cgi-bin':
    ensure  => directory,
    recurse => true,
    purge   => true,
    force   => true,
  }

  file { '/usr/lib/cgi-bin/it-works.pl':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => 755,
    source => 'puppet:///modules/apache_poller/it-works.pl',
  }

  file { '/usr/lib/cgi-bin/test.pl':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => 755,
    source => 'puppet:///modules/apache_poller/test.pl',
  }

  file { '/etc/perl/ShinkenPacks':
    ensure  => directory,
    recurse => true,
    purge   => true,
    force   => true,
    owner   => 'root',
    group   => 'root',
    mode    => 755,
  }

  file { '/etc/perl/ShinkenPacks/SNMP.pm':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => 755,
    source => 'puppet:///modules/apache_poller/SNMP.pm',
  }

  file { '/usr/bin/sp_check.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => 755,
    source => 'puppet:///modules/apache_poller/sp_check.sh',
  }

  package { ['libcurl4-openssl-dev', 'libssl-dev']:
    ensure => present,
  }

  file { '/root/sp_check.c':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => 644,
    source => 'puppet:///modules/apache_poller/sp_check.c',
  }

}


