class profiles::puppet::standard {

  $puppet_conf    = hiera_hash('puppet')

  $service_enable = $puppet_conf[client]['service_enable']
  $runinterval    = $puppet_conf[client]['runinterval']
  $pluginsync     = $puppet_conf[client]['pluginsync']

  # Test if the data has been well retrieved.
  if $service_enable == undef {
    fail("Problem in class ${title}, `service_enable` data not retrieved")
  }
  if $runinterval == undef {
    fail("Problem in class ${title}, `runinterval` data not retrieved")
  }
  if $pluginsync == undef {
    fail("Problem in class ${title}, `pluginsync` data not retrieved")
  }

  class { '::puppet::client':
    service_enable => $service_enable,
    runinterval    => $runinterval,
    pluginsync     => $pluginsync,
  }

}


