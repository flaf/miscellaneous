class airtime {

  include 'repositories::sourcefabric' # Add the sourcefabric repository.
  #include 'icecast2'

  Class['repositories::sourcefabric']

  ->

  # Workaround because during a package installation
  # Puppet reset the locale and UTF-8 is not set in
  # the PostgreSQL installation. And the airtime
  # installation failed if there no UTF-8 in PostgreSQL.
  # https://tickets.puppetlabs.com/browse/PUP-1191
  # Yes it sucks!
  exec { 'install-postgresql':
    user    => 'root',
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    command => 'sh -c "LC_ALL=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql"',
    unless  => 'dpkg -l postgresql | grep "^ii"',
  }

  ->

  package { 'airtime':
    ensure => present,
  }

  #->

  #Class['icecast2']

}


