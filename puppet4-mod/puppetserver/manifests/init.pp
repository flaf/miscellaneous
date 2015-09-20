# TODO: now there is no apache server. So one question: if
#       a certificate is in the CRL (certificate revocation
#       list), is it necessary to restart puppetserver to
#       have an effective revocation of the certificate.
#       Same check with Puppetdb.
class puppetserver (
  String[1]                    $puppet_memory,
  String[1]                    $puppetdb_memory,
  Enum['autonomous', 'client'] $profile,
  String                       $modules_repository,
  String[1]                    $puppetdb_name,
  String[1]                    $puppetdb_user,
  String[1]                    $puppetdb_pwd,
  Array[String[1], 1]          $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  include '::puppetserver::puppetconf'

  if $profile == 'autonomous' {

    class { '::puppetserver::postgresql':
      require => Class['::puppetserver::puppetconf'],
    }

    class { '::puppetserver::puppetdb':
      require => Class['::puppetserver::postgresql'],
    }

  }

}


