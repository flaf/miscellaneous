function httpproxy::get_option_value (
  String[1]                               $name,
  String[1]                               $option,
  Variant[String[1], Array[String[1], 1]] $value,
) {

  $special_options = Httpproxy::SquidguardList

  $return_value = case [$option, $value] {
    [$special_options, Any]  : { "${name}/${option}" }
    [Any,              Array]: { $value.join(' ')    }
    default                  : { $value              }
  };

  $return_value

}

