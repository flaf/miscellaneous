class basic_ssh::client {

  ::homemade::is_supported_distrib(['trusty', 'jessie'], $title)

  ensure_packages(['openssh-client', ], { ensure => present, })

}


