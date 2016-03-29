class puppetserver::backupetc {

  file { '/usr/local/sbin/save-etc.puppet':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
    source => 'puppet:///modules/puppetserver/save-etc.puppet',
  }

  cron { 'save-etc-cron':
    ensure  => present,
    user    => 'root',
    command => '/usr/local/sbin/save-etc.puppet',
    hour    => 3,
    minute  => 30,
    require => File['/usr/local/sbin/save-etc.puppet'],
  }

}


