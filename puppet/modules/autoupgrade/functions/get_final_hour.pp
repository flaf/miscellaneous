function autoupgrade::get_final_hour {

  include '::autoupgrade::params'

  $final_hour = $::autoupgrade::params::hour.lest || {
    $min = $::autoupgrade::params::hour_range[0]
    $max = $::autoupgrade::params::hour_range[1]
    $min + fqdn_rand($max-$min, 'upgradereboot-hour')
  }

  $final_hour

}


