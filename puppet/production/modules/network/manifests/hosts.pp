class network::hosts (
  $stage = 'network',
) {

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Module `${module_name}` is not supported or not yet tested on ${::lsbdistcodename}.")
    }
  }

  file { '/etc/hosts':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('network/hosts.erb'),
  }

}

