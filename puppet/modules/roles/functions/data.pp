function roles::data {

  $dcs = $datacenters ? {
    NotUndef => $datacenters,
    default  => [],
  }

  $dc = $datacenter ? {
    NotUndef => [ $datacenter ],
    default  => [],
  }

  $default_exchanges = ($dcs + $dc + ['mcollective']).unique.sort;

  {
    roles::mcomiddleware::params::exchanges => $default_exchanges,

    lookup_options => {
      roles::mcomiddleware::params::exchanges => { merge => 'unique' },
    },
  }

}


