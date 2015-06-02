class network::interfaces (
  Boolean $restart_network = false,
  Hash[ String[1],
        Hash[
              String[1],
              Variant[
                      String[1],
                      Array[String[1], 1],
                      Hash[String[1], String[1]]
                     ],
              2
            ],
        1
      ] $interfaces,
) {

  is_supported_distrib(['trusty'], $title)

}


