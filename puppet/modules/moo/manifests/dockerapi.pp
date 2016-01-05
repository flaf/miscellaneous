class moo::dockerapi {

  ensure_packages( [ 'python-pip' ], { ensure => present } )

  # With docker from Ubuntu Trusty repository, it's docker
  # version 1.6.2 and the API is version 1.18. So we need
  # to install docker-py version 1.2.3.
  exec { 'pip-install-docker-py':
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    command => 'pip install docker-py==1.2.3',
    unless  => "pip list | grep '^docker-py'",
  }

}


