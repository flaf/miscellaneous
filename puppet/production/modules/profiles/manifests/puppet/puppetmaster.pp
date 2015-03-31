class profiles::puppet::puppetmaster {

  if $::fqdn =~ /subpuppet/ {
    $ca_server = "puppet.${domain}"
  } else {
    $ca_server = undef
  }

  class { '::puppetmaster':
    server               => 'sumsum.flaf.fr',
    ca_server            => $ca_server,
    #puppetdb_user => 'joe',
    #admin_email   => 'sysadmin@domain.tld',
    hiera_git_repository => 'git@github.com:flaf/test-hiera.git',
  }

}


