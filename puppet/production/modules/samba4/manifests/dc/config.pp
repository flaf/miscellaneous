class samba4::dc::config {

  require 'samba4::dc::params'

  $realm         = $samba4::dc::params::realm
  $workgroup     = $samba4::dc::params::workgroup
  $dns_forwarder = $samba4::dc::params::dns_forwarder

  file { 'samba-provision-script':
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
    notify  => Service['samba'],
    content => template('samba4/dc_smb.conf.erb'),
  }

  file { 'resolv.conf':
    require => File['smb.conf'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    path    => '/etc/resolv.conf',
    content => "domain $domain\nsearch $domain\nnameserver $ipaddress\n\n",
  }

  service { 'samba':
    require    => File['smb.conf'],
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

}


