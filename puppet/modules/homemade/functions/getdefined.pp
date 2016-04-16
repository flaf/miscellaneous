function homemade::getdefined_bad (
  String[1] $var_name,
  String[1] $class_name,
) {

  $value = getvar($var_name)

  if $value =~ Undef {
    @("END"/L).fail
      ${class_name}: sorry the variable `${var_name}` is undefined \
      which is forbidden by the function `getdefined()`.
      |- END

      $title
  }

  $value

}


