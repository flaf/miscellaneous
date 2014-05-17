class samba4::install {

  require 'apt::backports'

  # It installs samba4.
  apt::force { ['samba', 'smbclient']:
    release => "$lsbdistcodename-backports",
    notify  => Exec['samba-provision'],
  }

  package { ['attr', 'samba-vfs-modules', 'acl']:
    require => Apt::Force['samba'],
    ensure  => present,
  }

  mount { 'root_fs':
    require  => Package['acl'],
    name     => '/',
    ensure   => mounted,
    options  => 'noatime,user_xattr,acl,errors=remount-ro',
    remounts => true,
  }

  file { 'patch-init-samba':
    require => Mount['root_fs'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    path    => '/etc//samba/init-samba.patch',
    content => template('samba4/init.patch.erb'),
  }

  file { 'samba-provision-script':
    require => File['patch-init-samba'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0754',
    path    => '/usr/local/sbin/samba-provision',
    content => template('samba4/samba-provision.erb'),
  }

  exec { 'samba-provision':
    require     => File['samba-provision-script'],
    path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    user        => 'root',
    command     => 'samba-provision',
    refreshonly => true,
  }

  file { 'smb.conf':
    require => Exec['samba-provision'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    path    => '/etc/samba/smb.conf',
    content => template('samba4/smb.conf.erb'),
  }

  service { 'samba':
    require    => File['smb.conf'],
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
  }

}


