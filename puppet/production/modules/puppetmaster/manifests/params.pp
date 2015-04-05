class puppetmaster::params {

  # The default values of some parameters.
  $puppet_server        = $::servername
  $ca_server            = $::servername
  $module_repository    = '<puppetforge>'
  $environment_timeout  = '10s'
  $puppetdb_server      = $::servername
  $puppetdb_dbname      = 'puppetdb'
  $puppetdb_user        = 'puppetdb'

  if $puppetdb_server == '<myself>' {
    $puppetdb_pwd       = md5($::fqdn)
  } else {
    $puppetdb_pwd       = md5($::servername)
  }

  $generate_eyaml_keys  = true
  $extdata              = { 'master_password' => sha1($::fqdn), }
  $admin_email          = "sysadmin@${::domain}"
  $hiera_git_repository = '<none>'

}


