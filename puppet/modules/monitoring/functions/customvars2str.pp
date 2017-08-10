function monitoring::customvars2str (
  Array[Monitoring::CustomVariable, 1] $custom_variables,
  Integer                              $indent = 0,
) >> String[1] {

  # The max size of a varname among the custom variables.
  $max = $custom_variables.map |$variable| {
    $variable['varname'].size
  }.reduce(0) |$memo, $entry| { max($memo, $entry) }

  $spaces        = inline_template('<%= " " * (@max + 1) %>')
  $indent_spaces = inline_template('<%= " " * @indent %>')

  $array = $custom_variables.map |$variable| {

    $value_str = case $variable['value'] {
      String: {
        $variable['value']
      }
      Array: {
        $variable['value'].join(', ')
      }
      Hash: {
        $variable['value'].reduce([]) |$memo, $a_value| {
          [$desc, $values] = $a_value
          $str = $values.join(')$ $(')
          $memo + "${desc}$(${str})$"
        }.join(", \\\n${$spaces}")
      }
    } # $value of the custom variables.

    $varname_str = ::homemade::ljust($variable['varname'], $max, ' ')
    $varline     = "${varname_str} ${value_str}"

    if 'comment' in $variable {
      $cmt = $variable['comment'].map |$c| {"# ${c}"}.join("\n")
      "${cmt}\n${varline}"
    } else {
    "${varline}"
    }

  }

  $array.map |$item| { $item.regsubst('^', $indent_spaces, 'G') }.join("\n")

}


