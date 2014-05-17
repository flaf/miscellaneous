class samba4::install {

  require 'apt::backports'

  # It installs samba4.
  apt::force { ['samba', 'smbclient']:
    release => "$lsbdistcodename-backports",
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

  file { 'samba-provision-script':
    require => Mount['root_fs'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0754',
    path    => '/usr/local/sbin/samba-provision',
    content => template('samba4/samba-provision.erb'),
  }

#  exec { 'samba-provision':
#    require     => File['samba-provision-script'],
#    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
#    user        => 'root',
#    command     => 'samba-provision',
#    refreshonly => true,
#  }

}


