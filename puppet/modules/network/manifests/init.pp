# TODO: I don't know why but a default value for the $stage
#       parameter is mandatory, else the puppet run just
#       fails:
#
#         stage is a metaparameter; please choose another
#         parameter name in the network definition at ... etc.
#
class network (
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if !defined(Class['::network::params']) { include '::network::params' }
  $interfaces = $::network::params::interfaces
  $restart    = $::network::params::restart

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

  file { '/usr/local/sbin/restart-network.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    before  => File['/etc/network/interfaces.puppet'],
    content => epp( 'network/restart-network.puppet.epp',
                    { 'rewrite_interfaces_bin' => $rewrite_interfaces_bin, },
                  ),
  }

  file { '/etc/network/interfaces.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp( 'network/interfaces.puppet.epp',
                    { 'interfaces' => $interfaces }
                  ),
  }

  if $restart {

    # Just to avoid a long line below.
    $ifaces_file = '/etc/network/interfaces'

    exec { 'restart-network-now':
      path    => '/usr/sbin:/usr/bin:/sbin:/bin',
      command => '/usr/local/sbin/restart-network.puppet',
      user    => 'root',
      group   => 'root',
      # Execute only when the files are different.
      unless  => "diff -q '${ifaces_file}' '${ifaces_file}.puppet'",
      # Normally if /etc/network/interfaces.puppet is already managed,
      # all others resources in this class are already managed too,
      # so all is ready for the restart.
      require => File['/etc/network/interfaces.puppet'],
    }
  }

}


