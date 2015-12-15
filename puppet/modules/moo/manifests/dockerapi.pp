class moo::dockerapi {

  ensure_packages( [ 'python-pip' ], { ensure => present } )

  exec { 'pip-install-docker-py':
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    command => 'pip install docker-py',
    unless  => "pip list | grep '^docker-py'",
  }

}


