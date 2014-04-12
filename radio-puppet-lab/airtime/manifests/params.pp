class airtime::params {

  $airtime_conf = hiera_hash('airtime', {})

  # Default value of the port number.
  if ($airtime_conf['port'] != '') {
    $port = $airtime_conf['port']
  } else {
    $port = '8080'
  }

  $postgre_pass = generate_password('__pwd__{"salt" => ["$fqdn", "postgreSQL"], "nice" => true, "max_length" => 16}')
  $rabbit_pass  = generate_password('__pwd__{"salt" => ["$fqdn", "rabbitMQ"], "case" => "upper", "nice" => true, "max_length" => 20}')
  $api_key      = generate_password('__pwd__{"salt" => ["$fqdn", "API_KEY"], "case" => "upper", "nice" => true, "max_length" => 20}')

}


