class puppetserver::backup {

  $mcrypt_pwd             = $::puppetserver::mcrypt_pwd
  $authorized_backup_keys = $::puppetserver::authorized_backup_keys

  ensure_packages( [ 'mcrypt' ], { ensure => present } )

  file { '/root/.mcryptrc':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => "algorithm rijndael-256\nkey ${mcrypt_pwd}\n",
    require => Package['mcrypt'],
    before  => Cron['save-etc-cron'],
  }

  # It's the result of this command:
  #
  #   mkpasswd --method=sha-512 --salt="$(openssl rand -hex 8)" "backup"
  #
  # So "backup" is the password. But we don't care here because
  # the password will be locked below.
  #
  $pwd = '$6$dcf5365f2a53c3b5$V17cV7d7TywPju3TvOnvcSSrfEDbb63MyLurxISdfjZEQyROfc2KfJomM0OyrT417.4z56uMzIrgA73/dIask.'

  user { 'ppbackup':
    name           => 'ppbackup',
    ensure         => present,
    expiry         => absent,
    managehome     => true,
    home           => "/home/ppbackup",
    password       => "!${pwd}", # <= password locked with "!".
    shell          => '/bin/bash',
    system         => false,
    purge_ssh_keys => true,
    before         => Cron['save-etc-cron'],
  }

  $authorized_backup_keys.each |String[1] $keyname, Puppetserver::Pubkey $pubkey| {

    ssh_authorized_key { "ppbackup~${keyname}":
      user    => 'ppbackup',
      type    => $pubkey['type'],
      # To allow ssh_public_keys in hiera in multilines with ">".
      key     => $pubkey['keyvalue'].regsubst(' ', '', 'G').strip,
      require => User['ppbackup'],
      before  => Cron['save-etc-cron'],
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
    require => File['/usr/local/sbin/save-etc.puppet'],
  }

}


