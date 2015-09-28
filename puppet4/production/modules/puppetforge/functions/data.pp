function puppetforge::data {

  $puppetforge_git_url = 'http://github.com/unibet/puppet-forge-server'
  # This is the commit which corresponds to the version 1.8.0 of this
  # software. It seems to work well.
  $commit_id           = '6f1b224a4e666c754876139f3643b22f3515f5e6'
  $remote_forge        = 'https://forgeapi.puppetlabs.com'
  $address             = '0.0.0.0'
  $port                = 8080
  $pause               = 300
  $modules_git_urls    = []
  $supported_distribs  = [ 'jessie' ];

  {
    puppetforge::puppetforge_git_url     => $puppetforge_git_url,
    puppetforge::commit_id               => $commit_id,
    puppetforge::remote_forge            => $remote_forge,
    puppetforge::address                 => $address,
    puppetforge::port                    => $port,
    puppetforge::pause                   => $pause,
    puppetforge::modules_git_urls        => $modules_git_urls,
    puppetforge::supported_distributions => $supported_distribs,
  }

}


