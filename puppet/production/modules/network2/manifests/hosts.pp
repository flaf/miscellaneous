class network2::hosts (
) {

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  file { '/etc/hosts.puppet.d':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,
  }

  file {'/etc/hosts.puppet.d/README':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "Directory managed by Puppet, don't touch it.\n",
  }

}


