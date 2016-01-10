function mongodb::data {

  # No default value. There will be an error if the
  # key is not found.
  $conf = lookup('mongo', Hash[String[1], Data, 1], 'hash');

  if $conf.has_key('bind_ip') {
  }

  $replset_tmp = "mongo-${domain}"

  $bind_ip = $conf['bind_ip'] ? {
    undef   => [ '0.0.0.0' ],
    default => $conf['bind_ip'],
  }

  $port = $conf['port'] ? {
    undef   => 27017,
    default => $conf['port'],
  }

  $auth = $conf['auth'] ? {
    undef   => false,
    default => $conf['auth'],
  }

  $replset = $conf['replset'] ? {
    undef   => $replset_tmp,
    default => $conf['replset'],
  }

  $smallfiles = $conf['smallfiles'] ? {
    undef   => true,
    default => $conf['smallfiles'],
  }

  $keyfile = $conf['keyfile'] ? {
    undef   => '',
    default => $conf['keyfile'],
  }

  $databases = $conf['databases'] ? {
    undef   => {},
    default => $conf['databases'],
  };

  {
    mongodb::params::bind_ip         => $bind_ip,
    mongodb::params::port            => $port,
    mongodb::params::auth            => $auth,
    mongodb::params::replset         => $replset,
    mongodb::params::smallfiles      => $smallfiles,
    mongodb::params::keyfile         => $keyfile,
    mongodb::params::databases       => $databases,
    mongodb::params::bind_ip         => $bind_ip,
    mongodb::supported_distributions => ['trusty'],
  }

}


