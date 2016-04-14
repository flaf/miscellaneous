function homemade::varname2value (
  Hash[ String[1], String[1], 1] $a_hash,
  String[1]                      $class_name,
) {

  $a_hash.reduce( {} ) |$memo, $entry| {

    [ $shortname, $name ] = $entry
    $value                = getvar($name)

    if $value =~ Undef {
      regsubst(@("END"), '\n', ' ', 'G').fail
        Sorry the value of the variable `${name}` is undefined
        in the class `${class_name}` and you must provided a value.
        |- END
    }

    $memo + { $shortname => $value }

  }

}


