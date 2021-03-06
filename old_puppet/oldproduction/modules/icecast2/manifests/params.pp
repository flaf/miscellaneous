class icecast2::params {

  $icecast2_conf = hiera_hash('icecast2', {})

  $git_directory    = 'mountpoints'
  $git_lockfile     = 'aware.lock'
  $mountpoints_file = 'mountpoints.xml'

  # Default value of fqdn_icecast
  if ($icecast2_conf['fqdn_icecast'] != '') {
    if ($icecast2_conf['fqdn_icecast'] == 'IP-ADDRESS') {
      $fqdn_icecast = $ipaddress
    } else {
      $fqdn_icecast = $icecast2_conf['fqdn_icecast']
    }
  } else {
    $fqdn_icecast = $::fqdn
  }


  # The default value of location.
  if ($icecast2_conf['location'] == '') {
    if ($datacenter == undef) {
      $location = $fqdn
    } else {
      $location = $datacenter
    }
  } else {
    $location = $icecast2_conf['location']
  }

  # The default value of official_admin_mail.
  if ($icecast2_conf['official_admin_mail'] == '') {
    if ($admin_email == undef) {
      $official_admin_mail = "admin@$fqdn"
    } else {
      $official_admin_mail = $admin_email
    }
  } else {
    $official_admin_mail = $icecast2_conf['official_admin_mail']
  }


  # The default value will be ''.
  $git_repository = $icecast2_conf['git_repository']

  # Default value of admins_mails
  if ($icecast2_conf['admins_mails'] != '') {
    $admins_mails = $icecast2_conf['admins_mails']
  } else {
    $admins_mails = []
  }

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

  # Default value of the ports.
  if ($icecast2_conf['ports'] != '') {
    $ports = $icecast2_conf['ports']
  } else {
    $ports = ['8000']
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

  # Default value of log level.
  if ($icecast2_conf['log_level'] != '') {
    $log_level = $icecast2_conf['log_level']
  } else {
    $log_level = '3'
  }

  # Default value of log size.
  if ($icecast2_conf['log_size'] != '') {
    $log_size = $icecast2_conf['log_size']
  } else {
    $log_size = '10000'
  }

}


