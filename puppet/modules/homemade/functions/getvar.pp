function homemade::getvar (
  Pattern[/^[_a-z0-9:]+$/] $var_name,
  String[1]                $class_name,
) {

  # Here, it's getvar() from the stdlib.
  $value = getvar($var_name)

  if defined("\$${var_name}") and $value =~ NotUndef {

    $value

  } else {

    @("END"/L).fail
      in ${class_name} the variable `${var_name}` \
      retrieved by homemade::getvar() is undefined \
      which is forbidden.
      |- END

  }

}


