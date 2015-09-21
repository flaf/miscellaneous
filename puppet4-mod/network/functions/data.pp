function network::data {

  $interfaces    = ::network::get_interfaces();
  $ifaces_dns    = ::network::get_interfaces_candidates_for('nameservers')
  $ifaces_search = ::network::get_interfaces_candidates_for('search')

  if $ifaces_dns.empty() {
    $nameservers = [ '8.8.8.8', '8.8.4.4' ]
  } else {
    $nameservers = $interfaces[$ifaces_dns[0]]['nameservers']
    unless $nameservers =~ Array[String[1], 1] {
      fail(regsubst(@(END), '\n', ' ', 'G'))
        Sorry, the `nameservers` key in the inventory networks
        must be a non-empty array of non-empty strings.
        |- END
    }
  }

  if $ifaces_search.empty() {
    $search = [ $::domain ]
  } else {
    $search = $interfaces[$ifaces_dns[0]]['search']
    unless $search =~ Array[String[1], 1] {
      fail(regsubst(@(END), '\n', ' ', 'G'))
        Sorry, the `search` key in the inventory networks
        must be a non-empty array of non-empty strings.
        |- END
    }
  };

  { network::restart                 => false,
    network::interfaces              => $interfaces,
    network::supported_distributions => [ 'trusty', 'jessie' ],
    network::stage                   => 'network',

    network::resolv_conf::domain      => $::domain,
    network::resolv_conf::search      => $search,
    network::resolv_conf::nameservers => $nameservers,
    network::resolv_conf::timeout     => 2,
  }

}


