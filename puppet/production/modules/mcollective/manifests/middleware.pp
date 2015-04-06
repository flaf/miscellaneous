class mcollective::middleware {

  ensure_packages( [ 'rabbitmq-server' ], { ensure => present, })

}


