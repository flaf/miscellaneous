class samba4::member::install {

  require 'apt::backports'

  apt::force { ['winbind', 'libnss-winbind']:
    release => "$lsbdistcodename-backports",
  }

  file { '/etc/nsswitch.conf':
    require => Apt::Force['libnss-winbind'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('samba4/nsswitch.conf.erb'),
  }

}


