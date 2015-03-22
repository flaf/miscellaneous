class puppetmaster::params {

  # The default values of some parameters.
  $server               = 'puppet'
  $module_repository    = undef
  $environment_timeout  = '10s'
  $puppetdb             = 'puppetdb'
  $puppetdb_user        = 'puppetdb'
  $puppetdb_pwd         = md5($::fqdn)
  $admin_email          = "sysadmin@${::domain}"
  $hiera_git_repository = undef

}


