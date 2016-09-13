class roles::gitlab {

  include '::roles::generic_nullclient'
  include '::repository::gitlab'

  class { '::gitlab':
    require => Class['::repository::gitlab']
  }

}


