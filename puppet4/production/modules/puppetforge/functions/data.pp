function puppetforge::data {

  $git_url            = 'http://github.com/unibet/puppet-forge-server'
  # This is the commit which corresponds to the 1.8.0 of this
  # software. It seems to work well.
  $commit_id          = '6f1b224a4e666c754876139f3643b22f3515f5e6'
  $remote_forge       = 'https://forgeapi.puppetlabs.com'
  $address            = '0.0.0.0'
  $port               = 8080
  $pause              = 300
  $giturls            = []
  $supported_distribs = [ 'jessie' ];

  {
    puppetforge::git_url                 => $git_url,
    puppetforge::commit_id               => $commit_id,
    puppetforge::remote_forge            => $remote_forge,
    puppetforge::address                 => $address,
    puppetforge::port                    => $port,
    puppetforge::pause                   => $pause,
    puppetforge::giturls                 => $giturls,
    puppetforge::supported_distributions => $supported_distribs,
  }

}


