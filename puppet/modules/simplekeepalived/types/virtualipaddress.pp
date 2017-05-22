type Simplekeepalived::VirtualIPAddress = Array[
  Struct[{
    'address' => Pattern[/\/[0-9]+$/],
    'label'   => String[1],
  }],
  1
]


