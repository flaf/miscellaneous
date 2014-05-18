class samba4::member::config {

  require 'samba4::member::params'

  $ip_dc = $samba4::member::params::ip_dc

  file { 'resolv.conf':
    require => File['smb.conf'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    path    => '/etc/resolv.conf',
    content => "domain $domain\nsearch $domain\nnameserver $ip_dc\n\n",
  }

}


