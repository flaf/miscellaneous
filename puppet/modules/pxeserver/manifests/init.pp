class pxeserver {

  $params = '::pxeserver::params'
  include $params
  $dhcp_confs             = ::homemade::getvar("${params}::dhcp_confs", $title)
  $no_dhcp_interfaces     = ::homemade::getvar("${params}::no_dhcp_interfaces", $title)
  $ip_reservations        = ::homemade::getvar("${params}::ip_reservations", $title)
  $host_records           = ::homemade::getvar("${params}::host_records", $title)
  $resolv_file            = ::homemade::getvar("${params}::resolv_file", $title)
  $puppet_collection      = ::homemade::getvar("${params}::puppet_collection", $title)
  $pinning_puppet_version = ::homemade::getvar("${params}::pinning_puppet_version", $title)
  $puppet_server          = ::homemade::getvar("${params}::puppet_server", $title)
  $puppet_ca_server       = ::homemade::getvar("${params}::puppet_ca_server", $title)
  $puppet_apt_url         = ::homemade::getvar("${params}::puppet_apt_url", $title)
  $puppet_apt_key         = ::homemade::getvar("${params}::puppet_apt_key", $title)

  $pxe_entries            = ::homemade::getvar("${params}::pxe_entries", $title)
  $distribs_provided      = ::homemade::getvar("${params}::distribs_provided", $title)


  $distribs_provided_array = $distribs_provided.keys
  $distribs_provided_str   = $distribs_provided_array.join(', ')
  $my_family               = $facts['os']['distro']['id'].downcase
  $my_ip                   = $facts['networking']['ip']
  $disable_dns             = $host_records.empty

  # Check that distribs are in provided distribs.
  $pxe_entries.each |$id, $settings| {

    $distrib = $settings['distrib']

    unless  $distrib in $distribs_provided_array {
      @("END"/L).fail
        $title: sorry the distribution `$distrib` is not \
        provided by the module $module_name. Currently, the \
        allowed distributions are $distribs_provided_str.
        |- END
    }

  }

  ensure_packages( [ 'dnsmasq',
                     'lsb-release',
                     'apache2',
                   ], { ensure => present } )

  file { '/srv':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    before  => File['/etc/dnsmasq.d/main.conf'],
    require => Package['dnsmasq'],
  }

  file { [ '/srv/tftp', '/srv/tftp/pxelinux.cfg' ]:
    ensure  => directory,
    owner   => 'dnsmasq',
    group   => 'root', # There is no group dnsmasq.
    mode    => '0755',
    before  => File['/etc/dnsmasq.d/main.conf'],
    require => Package['dnsmasq'],
  }

  file { '/srv/tftp/pxelinux.cfg/default':
    ensure  => present,
    owner   => 'dnsmasq',
    group   => 'root', # There is no group dnsmasq.
    mode    => '0644',
    before  => File['/etc/dnsmasq.d/main.conf'],
    require => Package['dnsmasq'],
    content => epp('pxeserver/pxe-default.epp',
                   {
                    'distribs_provided' => $distribs_provided,
                    'my_family'         => $my_family,
                    'my_ip'             => $my_ip,
                    'pxe_entries'       => $pxe_entries,
                   },
                  ),
  }

  file { '/usr/local/sbin/update-di.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    require => [ Package['dnsmasq'], File['/srv/tftp'] ],
    source  => 'puppet:///modules/pxeserver/update-di.puppet',
  }

  # Install the (debian|ubuntu)-installer of the current distribution.
  exec { 'populate-srv-tftp-installer':
    command => '/usr/local/sbin/update-di.puppet',
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => 'test -L /srv/tftp/pxelinux.0',
    before  => File['/etc/dnsmasq.d/main.conf'],
    require => File['/usr/local/sbin/update-di.puppet'],
  }

  # Install the kernel and initrd.gz of each provided distribution.
  $distribs_provided.keys.each |$distrib| {

    exec { "populate-srv-tftp-${distrib}":
      command => "/usr/local/sbin/update-di.puppet '${distrib}'",
      path    => '/usr/sbin:/usr/bin:/sbin:/bin',
      user    => 'root',
      group   => 'root',
      unless  => "test -d '/srv/tftp/${distrib}'",
      before  => File['/etc/dnsmasq.d/main.conf'],
      require => File['/usr/local/sbin/update-di.puppet'],
    }

  }

  file { '/etc/dnsmasq.d/main.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['dnsmasq'],
    require => Package['dnsmasq'],
    content => epp('pxeserver/dnsmasq-main.conf.epp',
                   {
                    'dhcp_confs'         => $dhcp_confs,
                    'no_dhcp_interfaces' => $no_dhcp_interfaces,
                    'domain'             => $::domain,
                    'disable_dns'        => $disable_dns,
                    'resolv_file'        => $resolv_file,
                   }
                  ),
  }

  file { "/etc/dnsmasq.d/reservations.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['dnsmasq'],
    require => Package['dnsmasq'],
    content => epp('pxeserver/dnsmasq-reservations.conf.epp',
                   { 'ip_reservations' => $ip_reservations, }
                  ),
  }

  file { "/etc/dnsmasq.d/host-records.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['dnsmasq'],
    require => Package['dnsmasq'],
    content => epp('pxeserver/dnsmasq-host-records.conf.epp',
                   { 'host_records' => $host_records, }
                  ),
  }

  service { 'dnsmasq':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => File['/etc/dnsmasq.d/main.conf'],
  }

  service { 'apache2':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => Package['apache2'],
  }

  # All files/directories which are not managed by Puppet
  # are deleted.
  file { '/var/www/html':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    purge   => true,
    recurse => true,
    force   => true,
  }

  file { '/var/www/html/index.html':
    ensure  => absent,
    require => Package['apache2'],
  }

  file { '/var/www/html/late-command-install-puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['apache2'],
    content => epp('pxeserver/late-command-install-puppet',
                   {
                    'puppet_collection'      => $puppet_collection,
                    'pinning_puppet_version' => $pinning_puppet_version,
                    'puppet_server'          => $puppet_server,
                    'puppet_ca_server'       => $puppet_ca_server,
                    'puppet_apt_url'         => $puppet_apt_url,
                    'puppet_apt_key'         => $puppet_apt_key,
                   },
                  ),
  }

  $pxe_entries.each |$id, $settings| {

    ::pxeserver::pxe_entry { "$id":
      distrib                    => $settings['distrib'],
      apt_proxy                  => $settings['apt_proxy'],
      partman_early_command_file => $settings['partman_early_command_file'],
      partman_auto_disk          => $settings['partman_auto_disk'],
      skip_boot_loader           => $settings['skip_boot_loader'],
      late_command_file          => $settings['late_command_file'],
      install_puppet             => $settings['install_puppet'],
      permitrootlogin_ssh        => $settings['permitrootlogin_ssh'],
      require                    => Package['apache2'],
    }

  }

}


