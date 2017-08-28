function roles::is_number_one() {

  case $::facts['networking']['hostname'] {
    /(01|-1)$/: { $result = true  }
    default:    { $result = false }
  };

  $result

}


