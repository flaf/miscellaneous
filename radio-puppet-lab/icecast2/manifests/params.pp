class icecast2::params {

  $icecast2_conf = hiera_hash('icecast2', {})

  # Default value of the source password.
  if ($icecast2_conf['source_password'] != '') {
    $source_password = $icecast2_conf['source_password']
  } else {
    $source_password = '__pwd__{"salt" => ["$fqdn", "source"], "nice" => true, "max_length" => 10 }'
  }

  # Default value of the admin password.
  if ($icecast2_conf['admin_password'] != '') {
    $admin_password = $icecast2_conf['admin_password']
  } else {
    $admin_password = '__pwd__{"salt" => ["$fqdn", "admin"], "nice" => true, "max_length" => 10 }'
  }

  # Default value of the port.
  if ($icecast2_conf['port'] != '') {
    $port = $icecast2_conf['port']
  } else {
    $port = '8000'
  }

  # Default value of max clients number.
  if ($icecast2_conf['limits_clients'] != '') {
    $limits_clients = $icecast2_conf['limits_clients']
  } else {
    $limits_clients = '100'
  }

  # Default value of max sources.
  if ($icecast2_conf['limits_sources'] != '') {
    $limits_sources = $icecast2_conf['limits_sources']
  } else {
    $limits_sources = '10'
  }

  # Default value of limit source timeout.
  if ($icecast2_conf['limits_source_timeout'] != '') {
    $limits_source_timeout = $icecast2_conf['limits_source_timeout']
  } else {
    $limits_source_timeout = '10'
  }

}


