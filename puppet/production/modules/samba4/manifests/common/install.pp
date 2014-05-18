class samba4::common::install {

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

}


