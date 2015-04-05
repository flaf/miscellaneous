class profiles::puppet::puppetmaster {

  if $::fqdn == 'puppet.athome.priv'  {

    class { '::puppetmaster':
      puppet_server        => '<myself>',
      ca_server            => '<myself>',
      module_repository    => '<puppetforge>',
      environment_timeout  => '0s',
      puppetdb_server      => '<myself>',
      puppetdb_dbname      => 'puppetdb',
      puppetdb_user        => 'puppetdb',
      puppetdb_pwd         => md5($::fqdn),
      generate_eyaml_keys  => true,
      admin_email          => undef,
      hiera_git_repository => 'git@github.com:flaf/test-hiera.git',
    }

  }

  if $::fqdn == 'subpuppet-1.athome.priv'  {

    class { '::puppetmaster':
      puppet_server        => 'puppet.athome.priv',
      ca_server            => 'puppet.athome.priv',
      module_repository    => '<puppetforge>',
      environment_timeout  => '0s',
      puppetdb_server      => 'puppet.athome.priv',
      puppetdb_dbname      => 'puppetdb',
      puppetdb_user        => 'puppetdb',
      puppetdb_pwd         => md5($::fqdn),
      generate_eyaml_keys  => false,
      admin_email          => undef,
      hiera_git_repository => '<none>',
    }

  }

}


