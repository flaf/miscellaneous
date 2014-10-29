class profiles::smssender {

  class {'::gammu_smsd':
    phones_to_test => []
  }

}

