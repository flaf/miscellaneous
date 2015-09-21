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


