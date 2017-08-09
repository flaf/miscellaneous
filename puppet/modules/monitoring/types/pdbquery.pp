type Monitoring::PdbQuery = Array[
  Struct[{
    title      => String[1],
    certname   => String[1],
    parameters => Monitoring::CheckPoint,
  }]
]


