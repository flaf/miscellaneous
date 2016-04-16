class mcollective::client_keys_dir {

  $client_keys_dir = $::mcollective::common_paths::client_keys_dir

  file { $client_keys_dir:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0500',
    recurse => true,
    purge   => true,
  }

}


