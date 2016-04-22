function puppetforge::data {

  $puppetforge_git_url = 'http://github.com/unibet/puppet-forge-server'
  $commit_id           = 'ab01f3376be081a426798b4333aed0ada920f637' # ie version 1.9.0.
  $remote_forge        = 'https://forgeapi.puppetlabs.com'
  $address             = '0.0.0.0'
  $port                = 8080
  $pause               = 180
  $modules_git_urls    = []
  $release_retention   = 5
  $sshkeypair          = undef
  $puppet_bin_dir      = undef
  $supported_distribs  = [ 'jessie' ]
  $sd                  = 'supported_distributions';

  {
    puppetforge::params::puppetforge_git_url => $puppetforge_git_url,
    puppetforge::params::commit_id           => $commit_id,
    puppetforge::params::remote_forge        => $remote_forge,
    puppetforge::params::address             => $address,
    puppetforge::params::port                => $port,
    puppetforge::params::pause               => $pause,
    puppetforge::params::modules_git_urls    => $modules_git_urls,
    puppetforge::params::release_retention   => $release_retention,
    puppetforge::params::sshkeypair          => $sshkeypair,
    puppetforge::params::puppet_bin_dir      => $puppet_bin_dir,
   "puppetforge::params::${sd}"              => $supported_distribs,
  }

}


