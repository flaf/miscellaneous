class airtime::params {

  $airtime_conf = hiera_hash('airtime', {})

  # Default value of the port number.
  if ($airtime_conf['port'] != '') {
    $port = $airtime_conf['port']
  } else {
    $port = '8080'
  }

}


