function distrib_repositories::data {

  case $::operatingsystem {

    'Debian': { $url = 'http://ftp.fr.debian.org/debian/' }
    'Ubuntu': { $url = 'http://fr.archive.ubuntu.com/ubuntu' }

  };

  { distrib_repositories::url                     => $url,
    distrib_repositories::src                     => false,
    distrib_repositories::install_recommends      => false,
    distrib_repositories::supported_distributions => [ 'trusty', 'jessie' ],
    distrib_repositories::stage                   => 'repository',
  }

}


