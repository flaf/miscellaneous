# TODO: now there is no apache server. So one question: if
#       a certificate is in the CRL (certificate revocation
#       list), is it necessary to restart puppetserver to
#       have an effective revocation of the certificate.
class puppetserver (
  String[1]           $puppet_memory,
  String[1]           $puppetdb_memory,
  Boolean             $retrieve_common_hiera,
  String[1]           $puppetdb_fqdn,
  String[1]           $ca_server,
  String[1]           $puppet_server_for_agent,
  String              $module_repository,
  String[1]           $puppetdb_name,
  String[1]           $puppetdb_user,
  String[1]           $puppetdb_pwd,
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if $puppetdb_fqdn == $::fqdn or $puppetdb_fqdn == '_myself_' {
    $puppetdb_myself = true
  } else {
    $puppetdb_myself = false
  }

  if $ca_server == $::fqdn or $ca_server == '_myself_' {
    $ca_myself = true
  } else {
    $ca_myself = false
  }

  if $puppet_server_for_agent == $::fqdn or $puppet_server_for_agent == '_myself_' {
    $puppetserver_for_myself = true
  } else {
    $puppetserver_for_myself = false
  }

  include '::puppetserver::puppetconf'

  if $puppetdb_myself {

    class { '::puppetserver::postgresql':
      require => Class['::puppetserver::puppetconf'],
    }

    class { '::puppetserver::puppetdb':
      require => Class['::puppetserver::postgresql'],
    }

  }

}


