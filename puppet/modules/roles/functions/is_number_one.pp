function roles::is_number_one {

  case $::hostname {
    /(01|-1)$/: { $result = true  }
    default:    { $result = false }
  };

  $result

}


