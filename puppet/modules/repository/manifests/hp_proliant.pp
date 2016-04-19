class repository::hp_proliant (
  String[1] $stage = 'repository',
) {

  include '::repository::hp_proliant::params'

  $url = $::repository::hp_proliant::params::url

  $key      = '882F7199B20F94BD7E3E690EFADD8D64B1275EA3'
  $codename = $::facts['lsbdistcodename']
  $comment  = "Hewlett-Packard ${codename} Repository: Management Component Pack for ProLiant (mcp)."

  # Use hkp on port 80 to avoid problem with firewalls etc.
  apt::key { 'hp_proliant':
    id     => $key,
    server => 'hkp://keyserver.ubuntu.com:80',
  }

  apt::source { "hp_proliant":
    comment  => $comment,
    location => $url,
    release  => "${codename}/current",
    repos    => 'non-free',
    include  => { 'src' => false, 'deb' => true },
    require  => Apt::Key['hp_proliant'],
  }

}


