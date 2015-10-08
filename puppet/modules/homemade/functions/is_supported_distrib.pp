function homemade::is_supported_distrib (
  Array[String[1], 1] $supp_distribs,
  String[1]           $class_name,
) {

  $codename = $::facts['lsbdistcodename']

  if !member($supp_distribs, $codename) {

    $supp_distribs_str = join($supp_distribs, ', ')

    fail(regsubst(@("END"), '\n', ' ', 'G'))
      Class `${class_name}` has never been tested on ${codename}.
      The supported distributions for this class are: ${supp_distribs_str}.
      |- END

  }

}


