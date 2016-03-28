function puppetforge::data {

  $puppetforge_git_url = 'http://github.com/unibet/puppet-forge-server'

  # This commit is the version 1.9.0.
  $commit_id           = 'ab01f3376be081a426798b4333aed0ada920f637'

  $remote_forge        = 'https://forgeapi.puppetlabs.com'
  $address             = '0.0.0.0'
  $port                = 8080
  $pause               = 180
  $modules_git_urls    = []
  $sshkeypair          = undef
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
    puppetforge::sshkeypair              => $sshkeypair,
  }

}


