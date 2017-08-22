type Monitoring::Blacklist = Array[
  Struct[{
    Optional['comment']   => Array[String[1]],
    'contact'             => String[1], # is a regex.
    Optional['host_name'] => String[1], # is a regex.
    'description'         => String,    # is a regex or the empty string (for a host check).

    # Example for timeslots:
    #
    #   [06h00;08h00][20h00;23h59]
    #
    'timeslots'           => Pattern[/^(\[([01]\d|2[01-3])h[0-5]\d;\+?([01]\d|2[01-3])h[0-5]\d\])+$/],

    # It's an array of _iso_ weekday ie from 1 to 7, or just the string '*'.
    'weekdays'            => Variant[Array[Integer[1,7], 1, 7], Enum['*']],
  }]
]


