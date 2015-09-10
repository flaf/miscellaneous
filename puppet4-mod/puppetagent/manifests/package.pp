class puppetagent::package ($stage = $::puppetagent::stage_package) {

  assert_private('puppetagent::package is a private class.')

  $key        = '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30'
  $collection = $::puppetagent::collection.downcase
  $collec_maj = $::puppetagent::collection.upcase
  $comment    = "Puppetlabs ${collec_maj} ${::lsbdistcodename} Repository."

  apt::source { "puppetlabs-${collection}":
    comment     => $comment,
    location    => 'http://apt.puppetlabs.com',
    release     => $::lsbdistcodename,
    repos       => $collec_maj,
    key         => $key,
    include_src => $::puppetagent::src,
    before      => Package['puppet-agent'],
  }

  # About pinning => `man apt_preferences`.
  apt::pin { 'puppet-agent':
    explanation => 'To ensure the version of the puppet-agent package.',
    packages    => 'puppet-agent',
    version     => $::puppetagent::package_version,
    priority    => 990,
    before      => Package['puppet-agent'],
  }

  ensure_packages(['puppet-agent', ], { ensure => present, })

}


