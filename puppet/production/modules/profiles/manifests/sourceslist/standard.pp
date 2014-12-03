class profiles::sourceslist::standard {

  # Should be equal to "debian" or "ubuntu".
  $os_family = downcase($::lsbdistid)

  $apt_conf        = hiera_hash('apt')
  $sourceslist_url = $apt_conf['sourceslist']['url'][$os_family]
  $add_src         = $apt_conf['sourceslist']['src']

  # Test if the data has been well retrieved.
  if $sourceslist_url == undef {
    fail("Problem in class ${title}, `sourceslist_url` data not retrieved.")
  }
  if $add_src == undef {
    fail("Problem in class ${title}, `add_src` data not retrieved.")
  }

  class { '::repositories::sourceslist':
    url     => $sourceslist_url,
    add_src => $add_src,
  }

}


