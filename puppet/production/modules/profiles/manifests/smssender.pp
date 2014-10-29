class profiles::smssender {

  class {'::gammu_smsd':
    phones_to_test => [ '0676553219' ],
    web_service    => true,
    limit_access   => [ 'localhost', '172.31.0.1' ],
  }

}

