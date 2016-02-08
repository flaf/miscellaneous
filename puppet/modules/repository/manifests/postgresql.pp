class repository::postgresql (
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  include '::repository::params'
  $url = $::repository::params::postgresql_url
  $src = $::repository::params::postgresql_src

  $codename = $::facts['lsbdistcodename']
  $key      = 'B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8'

  # Use hkp on port 80 to avoid problem with firewalls etc.
  apt::key { 'postgresql':
    id     => $key,
    server => 'hkp://keyserver.ubuntu.com:80',
  }

  apt::source { 'postgresql':
    comment  => 'PostgreSQL Repository.',
    location => "${url}",
    release  => "${codename}-pgdg",
    repos    => 'main',
    include  => { 'src' => $src, 'deb' => true },
    require  => Apt::Key['postgresql'],
  }

}


