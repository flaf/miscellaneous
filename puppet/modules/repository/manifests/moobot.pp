class repository::moobot {

  include '::repository::moobot::params'

  [
   $url,
   $key_url,
   $apt_key_fingerprint,
   $supported_distributions,
  ] = Class['::repository::moobot::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  repository::aptkey { 'moobot':
    id     => $apt_key_fingerprint,
    source => $key_url,
  }

  repository::sourceslist { 'moobot':
    comment    => 'Moobot Repository.',
    location   => $url,
    release    => 'moobot',
    components => [ 'main' ],
    src        => false,
    require    => Repository::Aptkey['moobot'],
  }

  # Provide a way to upgrade moobot through sudo (#7474)
  # NEVER tell flaf that I have done this addition!
  file { '/usr/local/sbin/moobot-upgrade.sh':
    content => "#!/bin/bash\napt-get update && apt-get install moobot\n",
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  } 

}


