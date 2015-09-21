function puppet_forge::data {

  $git_url      = 'http://github.com/unibet/puppet-forge-server'
  # This is the commit which corresponds to the 1.8.0 of this
  # software. It seems to work well.
  $commit_id    = '6f1b224a4e666c754876139f3643b22f3515f5e6'
  $remote_forge = 'https://forgeapi.puppetlabs.com'
  $address      = '0.0.0.0'
  $port         = 8080;
  $pause        = 60
  $giturls      = [];

  { puppet_forge::git_url                 => $git_url,
    puppet_forge::commit_id               => $commit_id,
    puppet_forge::remote_forge            => $remote_forge,
    puppet_forge::address                 => $address,
    puppet_forge::port                    => $port,
    puppet_forge::pause                   => $pause,
    puppet_forge::giturls                 => $giturls,
    puppet_forge::supported_distributions => [ 'jessie' ],
  }

}


