function memcached::data {

  # The unit is MiB.
  $default_memory = 64;

  {
    memcached::memory                  => $default_memory,
    memcached::supported_distributions => [ 'trusty' ],
  }

}


