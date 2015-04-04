class puppetmaster::params {

  # The default values of some parameters.
  $server               = $::servername
  $ca_server            = $::servername
  $module_repository    = '<puppet-forge>'
  $environment_timeout  = '10s'
  $puppetdb             = 'puppetdb'
  $puppetdb_user        = 'puppetdb'
  $puppetdb_pwd         = md5($::fqdn)
  $admin_email          = "sysadmin@${::domain}"
  $hiera_git_repository = '<none>'

}


