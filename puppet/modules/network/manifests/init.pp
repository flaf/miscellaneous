class network {

  include '::network::params'

  [
   $interfaces,
   #$restart,
   $supported_distributions,
  ] = Class['::network::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  ::network::check_interfaces($interfaces)

  # Normally, the "vlan" package is not necessary to have
  # VLAN. The "ifupdown" commands use the "ip" command.
  # Furthermore, it could be dangerous to add the "vlan"
  # package because, for instance, some proxmox packages are
  # incompatible with the "vlan" package: if you install the
  # "vlan" package some proxmox packages are automatically
  # removed.
  $packages = [
                'ifenslave',    # To have the bonding feature.
                'bridge-utils', # To have the bridge feature.
              ]
  ensure_packages( $packages,
                   { ensure => present,
                     before => File['/etc/network/interfaces.puppet'],
                   }
                 )

  # Rules to have persistent interface names.
  case $::facts['lsbdistcodename'] {

    /^(trusty|jessie)$/: {
      # The udev rule to force the name of interfaces
      # if the macaddress is given.
      file { '/etc/udev/rules.d/70-persistent-net.rules':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        before  => File['/etc/network/interfaces.puppet'],
        content => epp( 'network/70-persistent-net.rules.epp',
                        { 'interfaces' => $interfaces }
                      ),
      }
    }

    default: {

      # [i] If we change the name of an interface from "foo0" to "bar0",
      # the file /etc/systemd/network/10-bar0.link will be created but
      # the file /etc/systemd/network/10-foo0.link must be removed.
      file { '/etc/systemd/network':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        recurse => true,
        purge   => true, # <= [i]
        force   => false,
        before  => File['/etc/network/interfaces.puppet'],
      }

      $interfaces.filter |$ifname, $settings| {
        'macaddress' in $settings
      }.each |$ifname, $settings| {
        $macaddress = $settings['macaddress']
        file { "/etc/systemd/network/10-${ifname}.link":
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          before  => File['/etc/network/interfaces.puppet'],
          content => epp( 'network/10-ifname.link.epp',
                          { 'ifname' => $ifname, 'macaddress' => $macaddress }
                        ),
        }
      }

    } # End of default.

  } # End of case.

  file { '/etc/network/if-up.d/ignore_icmp_redirect':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/network/ignore_icmp_redirect',
    before => File['/etc/network/interfaces.puppet'],
    notify => Exec['ignore_icmp_redirect_now'],
  }

  exec { 'ignore_icmp_redirect_now':
    user        => 'root',
    command     => '/etc/network/if-up.d/ignore_icmp_redirect NOW',
    require     => File['/etc/network/if-up.d/ignore_icmp_redirect'],
    before      => File['/etc/network/interfaces.puppet'],
    refreshonly => true,
  }

  $rewrite_interfaces_bin = '/usr/local/sbin/rewrite-interfaces.puppet'

  file { $rewrite_interfaces_bin:
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
    source => 'puppet:///modules/network/rewrite-interfaces.puppet',
    before => File['/etc/network/interfaces.puppet'],
  }

  #file { '/usr/local/sbin/restart-network.puppet':
  #  ensure  => present,
  #  owner   => 'root',
  #  group   => 'root',
  #  mode    => '0750',
  #  before  => File['/etc/network/interfaces.puppet'],
  #  content => epp( 'network/restart-network.puppet.epp',
  #                  { 'rewrite_interfaces_bin' => $rewrite_interfaces_bin, },
  #                ),
  #}

  file { '/etc/network/interfaces.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp( 'network/interfaces.puppet.epp',
                    { 'interfaces' => $interfaces }
                  ),
  }

  #if $restart {

  #  # Just to avoid a long line below.
  #  $ifaces_file = '/etc/network/interfaces'

  #  exec { 'restart-network-now':
  #    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
  #    command => '/usr/local/sbin/restart-network.puppet',
  #    user    => 'root',
  #    group   => 'root',
  #    # Execute only when the files are different.
  #    unless  => "diff -q '${ifaces_file}' '${ifaces_file}.puppet'",
  #    # Normally if /etc/network/interfaces.puppet is already managed,
  #    # all others resources in this class are already managed too,
  #    # so all is ready for the restart.
  #    require => File['/etc/network/interfaces.puppet'],
  #  }
  #}

}


