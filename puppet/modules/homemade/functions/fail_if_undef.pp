function homemade::fail_if_undef (
  Any       $var_value,
  String[1] $var_name,
  String[1] $class_name,
  String    $additional_message = '',
) {

  if $var_value =~ Undef {

    $default_msg = @("END"/L)
      Sorry you can not let the variable `${var_name}` undefined \
      in the class `${class_name}`, you must provide a value.
      |- END

    case $additional_message == '' {
      true:  { $msg = $default_msg }
      false: { $msg = "$default_msg $additional_message"  }
    }

    fail($msg)

  }

}


