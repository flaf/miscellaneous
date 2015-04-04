class profiles::puppet::puppetmaster {

  if $::fqdn == 'puppet.athome.priv'  {

    class { '::puppetmaster':
      puppet_server        => '<my-self>',
      ca_server            => '<my-self>',
      module_repository    => '<puppet-forge>',
      environment_timeout  => '0s',
      puppetdb_server      => '<my-self>',
      puppetdb_dbname      => 'puppetdb',
      puppetdb_user        => 'puppetdb',
      puppetdb_pwd         => md5($::fqdn),
      admin_email          => undef,
      hiera_git_repository => 'git@github.com:flaf/test-hiera.git',
    }

  }

  if $::fqdn == 'subpuppet-1.athome.priv'  {

    class { '::puppetmaster':
      puppet_server        => '<my-self>',
      ca_server            => '<my-self>',
      module_repository    => '<puppet-forge>',
      environment_timeout  => '0s',
      puppetdb_server      => '<my-self>',
      puppetdb_dbname      => 'puppetdb',
      puppetdb_user        => 'puppetdb',
      puppetdb_pwd         => md5($::fqdn),
      admin_email          => undef,
      hiera_git_repository => 'git@github.com:flaf/test-hiera.git',
    }

  }

}


