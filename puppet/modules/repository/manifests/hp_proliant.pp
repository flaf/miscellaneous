class repository::hp_proliant {

  include '::repository::hp_proliant::params'

  [
   $url,
   $supported_distributions,
  ] = Class['::repository::hp_proliant::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $key      = '882F7199B20F94BD7E3E690EFADD8D64B1275EA3'
  $codename = $::facts['lsbdistcodename']
  $comment  = "Hewlett-Packard ${codename} Repository: Management Component Pack for ProLiant (mcp)."

  repository::aptkey { 'hp_proliant':
    id => $key,
  }

  repository::sourceslist { "hp_proliant":
    comment    => $comment,
    location   => $url,
    release    => "${codename}/current",
    components => [ 'non-free' ],
    src        => false,
    require    => Repository::Aptkey['hp_proliant'],
  }

}


