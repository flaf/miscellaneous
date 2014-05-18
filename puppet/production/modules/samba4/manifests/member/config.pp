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
  }

}


