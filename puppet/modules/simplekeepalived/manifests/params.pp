class simplekeepalived::params (
  Optional[Integer[0,255]]                     $virtual_router_id,
  String[1]                                    $interface,
  Integer[1,255]                               $priority,
  Boolean                                      $nopreempt,
  Optional[String[1]]                          $auth_pass,
  Optional[Simplekeepalived::VirtualIPAddress] $virtual_ipaddress,
  Optional[Simplekeepalived::TrackScript]      $track_script,
  Array[String[1], 1]                          $supported_distributions,
) {

  $default_track_script = {
    'interval' => 2,
    'weight'   => 0,
    'fall'     => 2,
    'rise'     => 1,
  }

}


