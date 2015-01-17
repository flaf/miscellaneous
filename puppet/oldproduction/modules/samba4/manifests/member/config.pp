class samba4::member::config {

  require 'samba4::common::params'
  require 'samba4::member::params'

  $realm        = $samba4::common::params::realm
  $workgroup    = $samba4::common::params::workgroup
  $netbios_name = $samba4::common::params::netbios_name
  $ip_dc        = $samba4::member::params::ip_dc

  file { 'resolv.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    path    => '/etc/resolv.conf',
    content => "domain $domain\nsearch $domain\nnameserver $ip_dc\n\n",
  }

  file { 'smb.conf':
    require => File['resolv.conf'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    path    => '/etc/samba/smb.conf',
    content => template('samba4/member_smb.conf.erb'),
    notify  => Service['samba'],
  }

  service { 'samba':
    subscribe   => File['smb.conf'],
    ensure     => running,
    hasstatus  => true,
    hasrestart => false,
    # With the samba package version 4.1.7 (backports),
    # there are errors in the init script with the restart
    # argument.
    restart    => '/etc/init.d/samba stop ; sleep 1 ; /etc/init.d/samba start ; sleep 1',
    # Because Samba is the DNS server, it's better to wait 1 second
    # after the start (or the restart) to be sure that the DNS is running.
    start      => '/etc/init.d/samba start ; sleep 1',
  }

  service { 'winbind':
    subscribe   => File['smb.conf'],
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
  }

}


