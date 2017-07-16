type Puppetagent::Cron = Variant[
  Enum['per-day', 'per-week', 'disabled'],
  Struct[{
    'per-day'  => Struct[{
                    Optional['hour']   => Integer[0,23],
                    Optional['minute'] => Integer[0,59],
                  }],
  }],
  Struct[{
    'per-week' => Struct[{
                    Optional['hour']    => Integer[0,23],
                    Optional['minute']  => Integer[0,59],
                    Optional['weekday'] => Integer[0,6],
                  }],
  }],
]


