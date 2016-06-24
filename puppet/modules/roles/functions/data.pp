function roles::data {

  # Warning: most parameters are defined in the classes
  #          ::roles::*::defaults. It's just a workaround,
  #          specific for this "roles" module, to not use a
  #          big only one data() function for all "role"
  #          classes.
  #
  #          Normally, only some specific merging policies
  #          will be defined in this function via the key
  #          "lookup_options".

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


