function homemade::fail_if_undef (
  Any       $var_value,
  String[1] $var_name,
  String[1] $class_name,
) {

  if $var_value =~ Undef {
    @("END"/L).fail
      Sorry you can not let the variable `${var_name}` undefined \
      in the class `${class_name}`, you must provided a value.
      |- END
  }

}


