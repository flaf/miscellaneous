type Simplekeepalived::TrackScript = Struct[{
  'script'             => String[1],
  Optional['interval'] => Integer[1],
  Optional['weight']   => Integer[0],
  Optional['fall']     => Integer[1],
  Optional['rise']     => Integer[1],
}]


