class network::resolv_conf {

  include '::network::resolv_conf::params'

  $domain            = $::network::resolv_conf::params::domain
  $search            = $::network::resolv_conf::params::search
  $timeout           = $::network::resolv_conf::params::timeout
  $override_dhcp     = $::network::resolv_conf::params::override_dhcp
  $dns_servers       = $::network::resolv_conf::params::dns_servers
  $local_resolver    = $::network::resolv_conf::params::local_resolver
  $lr_interface      = $::network::resolv_conf::params::local_resolver_interface
  $lr_access_control = $::network::resolv_conf::params::local_resolver_access_control
  $interfaces        = $::network::resolv_conf::params::interfaces

  # Get the interfaces configured via DHCP.
  $dhcp_ifaces = $interfaces.filter |$ifname, $settings| {
    $dhcp_families = ['inet', 'inet6'].filter |$family| {
      if $settings.has_key($family) and $settings[$family]['method'] == 'dhcp' {
        true
      } else {
        false
      }
    }
    !$dhcp_families.empty
  }

  if $override_dhcp {
    $manage_resolv_conf = true
  } else {
    if $dhcp_ifaces.empty {
      # No DHCP interfaces, we manage resolf.conf.
      $manage_resolv_conf = true
    } else {
      # There is at least one DHCP interface, so we don't
      # manage resolv.conf.
      $manage_resolv_conf = false
    }
  }

  # Test irrelevant cases.
  if $manage_resolv_conf and $dns_servers =~ Undef {
    @("END").regsubst('\n', ' ', 'G').fail
      $title: sorry the class intends to manage /etc/resolv.conf
      but the parameter `::network::params::dns_servers` is undef.
      |- END
  }

  if $local_resolver and $dns_servers =~ Undef {
    @("END").regsubst('\n', ' ', 'G').fail
      $title: sorry the class intends to configure a local resolver
      but the parameter `::network::params::dns_servers` is undef.
      |- END
  }

  if $local_resolver {

    ensure_packages(['unbound'],
                    {
                     ensure => present,
                     before => Service['unbound'],
                     notify => Service['unbound'],
                    }
                   )

    file { '/etc/unbound/unbound.conf.d/forward.conf':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['unbound'],
      before  => Service['unbound'],
      notify  => Service['unbound'],
      content => epp('network/unbound.forward.conf.epp',
                     { 'dns_servers' => $dns_servers, }
                    ),
    }

    if $lr_interface.empty and $lr_access_control.empty {
      $ensure_server_conf = 'absent'
    } else {
      $ensure_server_conf = 'present'
    }

    # If 127.0.0.1 not present in the interfaces, we add it.
    if $lr_interface.member('127.0.0.1') {
      $lr_ifaces = $lr_interface
    } else {
      $lr_ifaces = $lr_interface.concat('127.0.0.1')
    }

    file { '/etc/unbound/unbound.conf.d/server.conf':
      ensure  => $ensure_server_conf,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['unbound'],
      before  => Service['unbound'],
      notify  => Service['unbound'],
      content => epp('network/unbound.server.conf.epp',
                     {
                      'interface'      => $lr_ifaces,
                      'access_control' => $lr_access_control,
                     }
                    ),
    }

    # We move the file which configures unbound to use
    # the root DNS. Thus, the file will no be included
    # in the configuration. The /etc/unbound/unbound.conf
    # contains this line:
    #
    #   include: "/etc/unbound/unbound.conf.d/*.conf"
    #
    # After the mv command, the file will not be retrieved
    # by unbound.
    $file_auto_trust = '/etc/unbound/unbound.conf.d/root-auto-trust-anchor-file.conf'
    $cmd             = "mv '${file_auto_trust}' '${file_auto_trust}.disabled'"

    exec { 'unbound-disable-root-auto-trust':
      path    => '/usr/sbin:/usr/bin:/sbin:/bin',
      command => $cmd,
      onlyif  => "test -f '${file_auto_trust}'",
      before  => Service['unbound'],
      notify  => Service['unbound'],
    }

    if $::lsbdistcodename == 'jessie' {
      # On Debian Jessie like in Trusty, the service uses a
      # sysvinit script to start, but in Jessie the default
      # provider is "systemd" so we have to tell Puppet that
      # for this service the activation is via sysvinit and
      # not via systemd. "debian" provider is sysvinit in fact.
      $unbound_provider = 'debian'
    } else {
      $unbound_provider = undef
    }

    service { 'unbound':
      ensure     => running,
      hasstatus  => true,
      hasrestart => true,
      enable     => true,
      require    => Exec['unbound-disable-root-auto-trust'],
      before     => File['/etc/resolv.conf'],
      provider   => $unbound_provider,
    }

  } # Enf of if $local_resolver.

  # If no DHCP, we can manage the content of the resolv.conf
  # file. Indeed, if at least one interface is configured
  # via DHCP, the content of this file will be (and should
  # be) updated via the DHCP mechanism, not via Puppet. It
  # seems to me more logical.
  if $manage_resolv_conf {

    if $local_resolver {
      $nameservers = [ '127.0.0.1' ] + $dns_servers
    } else {
      $nameservers = $dns_servers
    }

    $resolv_conf_content = epp('network/resolv.conf.epp',
                               {
                                 'domain'         => $domain,
                                 'search'         => $search,
                                 'nameservers'    => $nameservers,
                                 'timeout'        => $timeout,
                               }
                              )
  } else {
    # There is DHCP configuration, we don't manage the
    # content of the /etc/resolv.conf file.
    $resolv_conf_content = undef
  }

  # With "ensure => file" is the file is a symlink to
  # "../run/resolvconf/resolv.conf", the symlink will
  # be removed and replaced by a regular file. So,
  # resolvconf mechanism will be disabled.
  #
  #
  # TODO: the "resolvconf" case (only with Trusty)
  #
  # In fact, this is not enough. For instance, on
  # Ubuntu Trusty with unbound, I have some problems.
  # During a restart of unbound I have:
  #
  #   ~# service unbound restart
  #    * Restarting recursive DNS server unbound
  #     /etc/resolvconf/update.d/libc: Warning: /etc/resolv.conf is not a symbolic link to /run/resolvconf/resolv.conf
  #     /etc/resolvconf/update.d/libc: Warning: /etc/resolv.conf is not a symbolic link to /run/resolvconf/resolv.conf
  #
  # And I have strange behaviors of unbound. After the
  # remove of "resolvconf" and a reboot, all is fine.
  # The remove of "resolvconf" triggers a remove of
  # "ubuntu-minimal" (because of dependency). And in
  # the description of this package, we can see it's
  # not recommended to remove it. But I have no other
  # solution and I have noticed no problem to remove
  # the "ubuntu-minimal" package so far.
  #
  #
  # Warning: during a manual `apt-get purge resolvconf`
  # we have a message that says "a reboot is needed after
  # the remove".
  package { 'resolvconf':
    ensure => purged,
    before => File['/etc/resolv.conf'],
  }

  file { '/etc/resolv.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $resolv_conf_content,
  }

}


