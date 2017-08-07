type Monitoring::CustomVariable = Struct[{
  varname => Pattern[/^_[a-zA-Z0-9_]+$/],
  value   => Variant[
               String[1],            # Value is a string,
               Array[String[1], 1],  # or value is an Array of string(s),
               Hash[
                 Pattern[/^[-._a-z0-9]+$/],
                 Array[String, 1],
                 1
               ],                    # or value is multivalued keys.
             ]

}]


