function puppetforge::data {

  $puppetforge_git_url = 'https://github.com/unibet/puppet-forge-server'
  $http_proxy          = undef
  $https_proxy         = undef
  $commit_id           = '7925c3943adbd505c71252f235b05102947dd91a'
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
    puppetforge::params::http_proxy          => $http_proxy,
    puppetforge::params::https_proxy         => $https_proxy,
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


