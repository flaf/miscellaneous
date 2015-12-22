function network::get_addresses (
  Hash[String[1], Hash[String[1], Data, 1], 1] $interfaces,
) {

  $addresses = $interfaces.reduce( [] ) |$memo, $entry| {

    $iface    = $entry[0]
    $settings = $entry[1]

    $new_addresses = [ 'inet', 'inet6' ].reduce ( [] ) |$memo, $family| {

      if $settings.has_key($family) and $settings[$family].has_key('options')
      and $settings[$family]['options'].has_key('address') {
        $new_addr = $memo.concat( $settings[$family]['options']['address'] )
      } else {
        $new_addr = $memo
      };

      $new_addr

    };

    $memo.concat($new_addresses)

  };

  $addresses

}


