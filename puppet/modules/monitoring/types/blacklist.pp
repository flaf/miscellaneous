type Monitoring::Blacklist = Array[
  Struct[{
    'contact'     => String[1],
    'host_name'   => Monitoring::Hostname,
    'description' => String,
    'timeslots'   => Pattern[/^(\[([01]\d|2[01-3])h[0-5]\d;([01]\d|2[01-3])h[0-5]\d\])+$/],
    'weekdays'    => Variant[Array[Integer[1,7], 1, 7], Enum['*']],
  }]
]


