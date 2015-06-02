class network::interfaces (
  Boolean $restart_network = false,
  Hash[ String[1],
        Hash[
              String[1],
              Variant[
                      String[1],
                      Array[String[1], 1],
                      Hash[String[1], String[1], 1]
                     ],
              2
            ],
        1
      ] $interfaces,
) {

  is_supported_distrib(['trusty'], $title)

  # Check the $interfaces variables.
  $interfaces.each |$interface, $settings| {

    unless has_key($settings, 'method') {
      fail(regsubst(@("END"), '\n', ' ', 'G'))
      The interface ${interface} must have a 'method' key,
      this is not the case currently.
      |- END
    }

    unless is_string($settings['method']) {
      fail(regsubst(@("END"), '\n', ' ', 'G'))
      The value of the 'method' key of interface ${interface}
      must be a non empty string, this is not the case currently.
      |- END
    }

    if has_key($settings, 'options') {
      unless is_hash($settings['options']) {
        fail(regsubst(@("END"), '\n', ' ', 'G'))
        The value of the 'options' key of interface ${interface}
        must be a non empty hash, this is not the case currently.
        |- END
      }
    }

  }

}


