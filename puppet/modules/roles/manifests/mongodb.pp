class roles::mongodb {

  include '::roles::generic'
  include '::mongodb'

  $fqdn = $::facts['networking']['fqdn']

  monitoring::host::checkpoint {"${fqdn} from ${title}":
    templates => ['mongodb-rs_tpl'],
  }

}


