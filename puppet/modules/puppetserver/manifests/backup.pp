class puppetserver::backup {

  $mcrypt_pwd             = $::puppetserver::mcrypt_pwd
  $authorized_backup_keys = $::puppetserver::authorized_backup_keys


  ::ppbackup::mcrypt_user { 'root':
    password => $mcrypt_pwd,
    before   => Cron['save-etc-cron'],
  }

  $authorized_backup_keys.each |String[1] $keyname, Puppetserver::Pubkey $pubkey| {

    ::ppbackup::ssh_authorized_key { "${keyname}":
      type   => $pubkey['type'],
      key    => $pubkey['keyvalue'],
      before => Cron['save-etc-cron'],
    }

  }

  file { '/usr/local/sbin/save-etc.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/puppetserver/save-etc.puppet',
    before  => Cron['save-etc-cron'],
  }

  cron { 'save-etc-cron':
    ensure  => present,
    user    => 'root',
    command => '/usr/local/sbin/save-etc.puppet',
    hour    => 3,
    minute  => 30,
  }

}


