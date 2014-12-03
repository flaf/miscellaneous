# TODO: write the documentation header.
#
class repositories::sourceslist (
  $stage   = repository,
  $url     = $::repositories::sourceslist::params::url,
  $add_src = false,
) inherits ::repositories::sourceslist::params {

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  # Check parameters.
  unless is_string($url) and (! empty($url)) {
    fail("Problem in class ${title}, the `url` parameter must be a non empty string.")
  }
  unless is_bool($add_src) {
    fail("Problem in class ${title}, the `add_src` parameter must be a boolean.")
  }

  # Should be equal to "debian" or "ubuntu".
  $os_family = downcase($::lsbdistid)

  file { '/etc/apt/sources.list':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("repositories/sourceslist/sources.list.${os_family}.erb"),
  }

  exec { 'sourceslist-apt-get-update':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => 'apt-get update',
    user        => 'root',
    group       => 'root',
    refreshonly => true,
    require     => File['/etc/apt/sources.list'],
    subscribe   => File['/etc/apt/sources.list'],
  }

}


