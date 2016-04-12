type Snmp::Community = Struct[
  {
    'name'   => String[1],
    'access' => Array[
                  Struct[
                    {
                      'source'         => String[1],
                      Optional['view'] => String[1],
                    }
                  ],
                1],
  }
]


