class repository::hp_proliant {

  include '::repository::hp_proliant::params'

  [
   $url,
   $supported_distributions,
  ] = Class['::repository::hp_proliant::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $key      = '57446EFDE098E5C934B69C7DC208ADDE26C2B797'
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


