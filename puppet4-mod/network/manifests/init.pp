class network (
  Boolean                                      $restart,
  Hash[String[1], Hash[String[1], Data, 1], 1] $interfaces,
  Array[String[1], 1]                          $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)
  ::network::check_interfaces($interfaces)

  $packages = [ 'vlan',         # To have the vlan feature.
                'ifenslave',    # To have the bonding feature.
                'bridge-utils', # To have the bridge feature.
              ]
  ensure_packages($packages, { ensure => present, })

  # The command to restart the network properly.
  $restart_network_cmd = @(END)
    ifdown --all
    sleep 0.5

    if [ -f '/etc/network/interfaces.puppet' ]
    then
      cat '/etc/network/interfaces.puppet' >'/etc/network/interfaces'
    fi

    # Refresh the names of interfaces.
    udevadm control --reload-rules
    sleep 0.25
    udevadm trigger --subsystem-match='net' --action='add'
    sleep 0.25

    # Configure all interfaces marked 'auto'.
    ifup --all
    sleep 0.25
    | END

  file { '/etc/network/interfaces.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp( 'network/interfaces.puppet.epp',
                    { 'interfaces' => $interfaces }
                  ),
  }

  # Remark about "resolvconf"
  #
  # Trusty uses the package "resolvconf" by default and it's
  # not recommended to remove "resolvconf" in Trusty (if you
  # do that, you will remove the "ubuntu-minimal" package that
  # is not recommended). To come back to the classical
  # /etc/resolv.conf in Trusty, just keep the "resolvconf"
  # package and replace the symlink /etc/resolv.conf by a
  # regular file.

}


