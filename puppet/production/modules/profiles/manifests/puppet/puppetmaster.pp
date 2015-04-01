class profiles::puppet::puppetmaster {

  if $::fqdn =~ /subpuppet/ {
    $ca_server = "puppet.${domain}"
    $server    = "puppet.${domain}"
  } else {
    $ca_server = undef
    $server    = 'sumsum.flaf.fr'
  }

  class { '::puppetmaster':
    server               => $server,
    ca_server            => $ca_server,
    environment_timeout  => '0s',
    #puppetdb_user => 'joe',
    #admin_email   => 'sysadmin@domain.tld',
    hiera_git_repository => 'git@github.com:flaf/test-hiera.git',
  }

}


