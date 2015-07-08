class network::interfaces (
  Boolean $restart_network,
  Hash[String[1], Hash[String[1], Data, 1], 1] $interfaces,
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  notify { 'Test1': message => $interfaces }

  $interfaces.each |$ifname, $interface| {
    #::network::check_interface($interface.merge({ 'name' => $ifname }))
    ::network::check_interface( { $ifname => $interface } )
  }

  notify { 'Test2': message => $interfaces }

  # (*)
  # Trusty uses "resolvconf" by default and it's not
  # recommended to remove "resolvconf" in Trusty (if you do
  # that, you will remove the "ubuntu-minimal" package that
  # is not recommended).
  $packages = [
               'resolvconf', # (*)
               'vlan',       # To have vlan features.
               'ifenslave',  # To have bonding features.
              ]
  ensure_packages($packages, { ensure => present, })

  $restart_network_cmd = @(END)
    ifdown --all
    sleep 0.5

    if [ -f '/etc/network/interfaces.puppet' ]
    then
      cat '/etc/network/interfaces.puppet' > '/etc/network/interfaces'
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
    content => epp(
                   'network/interfaces.puppet.epp',
                   { 'interfaces' => $interfaces }
                  ),
  }

}


