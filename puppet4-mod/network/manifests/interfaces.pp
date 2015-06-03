class network::interfaces (
  Boolean $restart_network = false,
  Hash[ String[1],
        Hash[
              String[1],
              Variant[
                      String[1],
                      Hash[String[1], String[1], 1]
                     ],
              2
            ],
        1
      ] $interfaces,
) {

  is_supported_distrib(['trusty'], $title)

  # Allowed keys in an interface hash.
  $allowed_keys = [
                   'method',
                   'options',
                   'network-name',
                   'comment',
                   'macaddress',
                  ]

  $restart_network_cmd = @(END)
    ifdown --all
    sleep 0.5

    if [ -f '/etc/network/interfaces.puppet' ]
    then
      cat '/etc/network/interfaces.puppet' > '/etc/network/interfaces'
    fi

    # Refresh the names of interfaces.
    udevadm control --reload-rules
    sleep 0.5
    udevadm trigger --subsystem-match='net' --action='add'
    sleep 0.5

    # Configure all interfaces marked 'auto'.
    ifup --all
    sleep 0.5
    | END

  # Check the $interfaces variable.
  $interfaces.each |$interface, $settings| {

    # The 'method' key is mandatory.
    unless has_key($settings, 'method') {
      fail(regsubst(@("END"), '\n', ' ', 'G'))
      The interface '${interface}' must have a 'method' key,
      this is not the case currently.
      |- END
    }

    $settings.each |$param, $value| {

      # Check if the keys of the interface are allowed.
      unless member($allowed_keys, $param) {
        fail(regsubst(@("END"), '\n', ' ', 'G'))
        The interface '${interface}' has a '${param}' key
        which is not allowed.
        |- END
      }

      # Check the type of each value.
      case $param {

        'options': {
          # The value of 'options' key must be a hash.
          unless is_hash($value) {
            fail(regsubst(@("END"), '\n', ' ', 'G'))
            The value of the '${param}' key of interface '${interface}'
            must be a non empty hash, this is not the case currently.
            |- END
          }
        }

        default: {
          # The value of the other keys must be a string.
          unless is_string($value) {
            fail(regsubst(@("END"), '\n', ' ', 'G'))
            The value of the '${param}' key of interface '${interface}'
            must be a non empty string, this is not the case currently.
            |- END
          }
        }

      }
    }
  }

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


